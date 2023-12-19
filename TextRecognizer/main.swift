//
//  main.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import CoreGraphics
import CoreImage
import Foundation
import Vision

guard CommandLine.arguments.count >= 3 else {
    print("""
          Invalid command line arguments, expected format:
          textRecognizer inputDir outputFileName [intermediateImageDir]
          """)
    exit(1)
}

guard let inputURL = URL(string: CommandLine.arguments[1]) else {
    print("Failed to find contents for directory \(CommandLine.arguments[1])")
    exit(1)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
var intermediateDir: URL?

if CommandLine.arguments.count >= 4 {
    if let url = URL(string: CommandLine.arguments[3]) {
        intermediateDir = url
    } else {
        print("Ignoring invalid intermediate URL")
    }
}

main(
    inURL: inputURL,
    textFileURL: outputURL,
    intermediateDir: intermediateDir
)


func main(inURL: URL, textFileURL: URL, intermediateDir: URL? = nil) {
    
    let imageProcessor = ImageProcessor()
    setupOutputFile(textFileURL)
    
    for file in getInputFilePaths(inURL) {
        print(file.lastPathComponent)
        guard let image = imageProcessor.process(file: file) else {
            print("Failed to process image")
            exit(1)
        }
        
        if let intermediateDir,
           let cgImage = ImageProcessor().cgImage(from: image) {
            writeImage(cgImage, to: intermediateDir, name: file.lastPathComponent)
        }
        
        requestTextRecognition(from: image) { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print(error ?? "Failed to get results")
                return
            }

            makePages(from: results).forEach {
                writeText($0, to: textFileURL)
            }
        }
    }
}

// MARK: Image management

func makePages(from observations: [VNRecognizedTextObservation]) -> [Page] {
    
    let leftPage = Page()
    let rightPage = Page()
    
    observations.forEach { observation in
        // Return the string of the top VNRecognizedText instance.
        guard let curString = observation.topCandidates(1).first?.string else {
            print("Found non-string observeration.")
            return
        }
        
        let curLine = Page.Line(
            text: curString,
            frame: observation.boundingBox)
        
        if observation.boundingBox.minX <= 0.5 {
            leftPage.lines.append(curLine)
        } else {
            rightPage.lines.append(curLine)
        }
    }
    
    return [leftPage, rightPage]
}

func requestTextRecognition(from image: CIImage,
                            completion: @escaping (VNRequest, Error?) -> Void) {
    
    let requestHandler = VNImageRequestHandler(ciImage: image)

    //// Create a new request to recognize text.
    let request = VNRecognizeTextRequest(completionHandler: completion)
    do {
        // Perform the text-recognition request.
        try requestHandler.perform([request])
    } catch {
        print("Unable to perform the requests: \(error).")
    }
}

// MARK: File and URL management

func getInputFilePaths(_ url: URL) -> [URL] {
    
    if url.isFileURL {
        return [url]
    }
    do {
        return try FileManager.default
            .contentsOfDirectory(atPath: url.path)
            .filter { !$0.hasPrefix(".") }
            .sorted(by: sortFileNames)
            .compactMap { url.appendingPathComponent($0) }
    }
    catch {
        print("Failed to find contents for directory \(error)")
        exit(1)
    }
}

func setupOutputFile(_ url: URL) {
    guard let data = "".data(using: .unicode) else {
        print("failed to make data from empty string? weird.")
        return
    }
    guard FileManager.default.fileExists(atPath: url.path) else {
        FileManager.default.createFile(
            atPath: url.path,
            contents: data
        )
        return
    }
    
    do {
        try data.write(to: url)
    } catch {
        print(error)
    }
}

func sortFileNames(lhs: String, rhs: String) -> Bool {
    guard let leftFileNumStr = lhs.split(separator: ".").first?.split(separator: "-").last,
       let rightFileNumStr = rhs.split(separator: ".").first?.split(separator: "-").last,
       let leftFileNum = Int(leftFileNumStr),
       let rightFileNum = Int(rightFileNumStr) else {
        print("invalid fileName: \"\(lhs)\" or \"\(rhs)\". Expected format: [name]-[integer].[extension]")
        exit(1)
    }
    return leftFileNum < rightFileNum
}

func writeImage(_ image: CGImage, to dir: URL, name: String) {
    if let writeURL = URL(string: "file://\(dir.appendingPathComponent(name))"),
       let dest = CGImageDestinationCreateWithURL(writeURL as CFURL,
                                                   kUTTypePNG, 1, nil) {
        CGImageDestinationAddImage(dest, image, nil)
        let _ = CGImageDestinationFinalize(dest)
    } else {
        print("skipping intermediate image save")
    }
}

func writeText(_ page: Page, to url: URL) {
    guard let data = page.content.data(using: .unicode) else {
        print("Failed to convert Page content to data")
        exit(1)
    }
    do {
        let file = try FileHandle(forWritingTo: url)
        try file.seekToEnd()
        try file.write(contentsOf: data)
        try file.close()
    }
    catch {
        print(error.localizedDescription)
        exit(1)
    }
}
