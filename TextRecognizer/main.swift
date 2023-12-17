//
//  main.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import Foundation
import CoreGraphics
import Vision

main()

func main() {
    
    var resultText = ""
    
    let outPath = "/Users/matthewwylder/Desktop/textOutput.txt"
    let outURL = URL(fileURLWithPath: outPath)
    
    if !FileManager.default.fileExists(atPath: outPath) {
        FileManager.default.createFile(
            atPath: outPath,
            contents: "".data(using: .unicode)!
        )
    }
    
    // the pages are number 1-139
    for i in (1...3) {
        let curPath = "/Users/matthewwylder/Desktop/screencapture3/frame-\(i).png"
        requestVision(fromImageAt: curPath) { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                print(error ?? "Failed to get results")
                return
            }
            resultText.append(text(from: results))
        }
    }
    
    try! resultText.data(using: .unicode)?.write(to: outURL)
}

func requestVision(fromImageAt path: String,
                   completion: @escaping (VNRequest, Error?) -> Void) {
    let data = NSData(contentsOfFile: path)!
    let dataProvider = CGDataProvider(data: data)!
    let png = CGImage(pngDataProviderSource: dataProvider,
                      decode: nil,
                      shouldInterpolate: false,
                      intent: .defaultIntent)

    let requestHandler = VNImageRequestHandler(cgImage: png!)

    //// Create a new request to recognize text.
    let request = VNRecognizeTextRequest(completionHandler: completion)
    //
    do {
        // Perform the text-recognition request.
        try requestHandler.perform([request])
    } catch {
        print("Unable to perform the requests: \(error).")
    }
}

func text(from observations: [VNRecognizedTextObservation]) -> String {
    var outString = ""
    
    observations.forEach { observation in
        // Return the string of the top VNRecognizedText instance.
        guard let curString = observation.topCandidates(1).first?.string else {
            print("Found non-string observeration.")
            return
        }
        
        if let _ = Int(curString) {
            // this is probably a page number
            outString.append("\n\(curString)\n\n")
        } else {
            outString.append("\(curString) ")
        }
    }
    
    return outString
}
