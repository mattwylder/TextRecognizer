//
//  main.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import CoreGraphics
import Foundation
import Vision

/// the screenshots are numbered 1-139
let range = (2...2)

main()

func main() {
    
    let outPath = "/Users/matthewwylder/Desktop/textOutput.txt"
    var allPages = [Page]()
    setupFile(outPath)
    
    for i in range {
        let curPath = "/Users/matthewwylder/Desktop/screencapture3/frame-\(i).png"
        requestVision(fromImageAt: curPath) { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print(error ?? "Failed to get results")
                return
            }
            allPages.append(contentsOf: makePages(from: results))
        }
    }
    
    write(allPages, to: outPath)
}

func setupFile(_ path: String) {
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

func requestVision(fromImageAt path: String,
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
        guard var curString = observation.topCandidates(1).first?.string else {
            print("Found non-string observeration.")
            return
        }
        
        let curLine = Page.Line(
            text: curString,
            rightMargin: observation.boundingBox.maxX,
            baseline: observation.boundingBox.maxY)
        
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
