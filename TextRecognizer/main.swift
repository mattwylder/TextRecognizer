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

main(
    directory: CommandLine.arguments[1],
    outPath: CommandLine.arguments[2]
)

func main(directory: String, outPath: String) {
    guard let fileNames = getInputFilePaths(directory) else {
        print("Failed to find contents for directory \(directory)")
        return
    }
    var allPages = [Page]()
    setupOutputFile(outPath)
    
    for fileName in fileNames {
        print(fileName)
        requestTextRecognition(fromImageAt: fileName) { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print(error ?? "Failed to get results")
                return
            }
            allPages.append(contentsOf: makePages(from: results))
        }
    }
    write(allPages, to: outPath)
}

func getInputFilePaths(_ directory: String) -> [String]? {
    guard let directoryURL = URL(string: directory),
          let fileNames = try? FileManager.default.contentsOfDirectory(atPath: directory) else {
        print("Failed to find contents for directory \(directory)")
        return nil
    }
    return fileNames
        .sorted { $0 < $1 }
        .map { directoryURL.appendingPathComponent($0).absoluteString }
}

func setupOutputFile(_ path: String) {
    guard let data = "".data(using: .unicode) else {
        print("failed to make data from empty string? weird.")
        return
    }
    
    if !FileManager.default.fileExists(atPath: path) {
        FileManager.default.createFile(
            atPath: path,
            contents: data
        )
    }
}

func requestTextRecognition(fromImageAt path: String,
                            completion: @escaping (VNRequest, Error?) -> Void) {
    
    guard let png = makeImage(from: path) else {
        print("Failed to make CGImage for path \(path)")
        return
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: png)

    //// Create a new request to recognize text.
    let request = VNRecognizeTextRequest(completionHandler: completion)
    do {
        // Perform the text-recognition request.
        try requestHandler.perform([request])
    } catch {
        print("Unable to perform the requests: \(error).")
    }
}

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
        
        // if text is left of center
        if observation.boundingBox.maxX <= 0.5 {
            leftPage.lines.append(curLine)
        } else {
            rightPage.lines.append(curLine)
        }
    }
    
    return [leftPage, rightPage]
}

func write(_ pages: [Page], to path: String) {
    let url = URL(fileURLWithPath: path)
    var resultText = ""
    
    for page in pages {
        resultText.append(page.content)
    }
    
    try! resultText.data(using: .unicode)?.write(to: url)
}
