//
//  main.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import CoreGraphics
import Foundation
import Vision

guard CommandLine.arguments.count == 3 else {
    print("""
          Invalid command line arguments, expected format:
          textRecognizer [inputDir] [outputFileName]
          """)
    exit(1)
}

guard let inputURL = URL(string: CommandLine.arguments[1]) else {
    print("Failed to find contents for directory \(CommandLine.arguments[1])")
    exit(1)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

main(
    inURL: inputURL,
    outURL: outputURL
)

func main(inURL: URL, outURL: URL) {
    
    guard let fileNames = getInputFilePaths(inURL) else {
        print("Failed to find contents for directory \(inURL.path)")
        return
    }
    setupOutputFile(outURL)
    
    for fileName in fileNames {
        print(fileName)
        guard let image = makeImage(from: fileName) else {
            print("Aborting attempt to create CGImage from invalid path \(fileName)")
            return
        }
        
        let cropped = image.cropping(to: CGRect(x: 178, y: 35,
                                                width: 1433, height: 1145))!
        
        requestTextRecognition(from: cropped) { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print(error ?? "Failed to get results")
                return
            }
            
            makePages(from: results).forEach {
                write($0, to: outURL)
            }
        }
    }
}

// MARK: Image management

func makeImage(from path: String) -> CGImage? {
    guard let data = NSData(contentsOfFile: path),
          let dataProvider = CGDataProvider(data: data) else {
        print("Failed to make dataProvider for path \(path)")
        return nil
    }
    
    return CGImage(pngDataProviderSource: dataProvider,
                   decode: nil,
                   shouldInterpolate: false,
                   intent: .defaultIntent)
}

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

func requestTextRecognition(from image: CGImage,
                            completion: @escaping (VNRequest, Error?) -> Void) {
    
    let requestHandler = VNImageRequestHandler(cgImage: image)

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

func getInputFilePaths(_ url: URL) -> [String]? {
    
    if url.isFileURL {
        return [url.path]
    }
    do {
        return try FileManager.default
            .contentsOfDirectory(atPath: url.path)
            .filter { !$0.hasPrefix(".") }
            .sorted(by: sortFileNames)
            .map { url.appendingPathComponent($0).absoluteString }
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

func write(_ page: Page, to url: URL) {
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
