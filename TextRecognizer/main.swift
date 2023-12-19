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
          textRecognizer inputDir outputFileName [processedImageDir]
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
    sourceImageDir: inputURL,
    textFileURL: outputURL,
    processedImageDir: intermediateDir
)

func main(
    sourceImageDir: URL,
    textFileURL: URL,
    processedImageDir: URL? = nil) {
    
    let imageProcessor = ImageProcessor()
    setupOutputFile(textFileURL)
    
    for file in getInputFilePaths(sourceImageDir) {
        
        print(file.lastPathComponent)
        guard let image = imageProcessor.process(file: file) else {
            print("Failed to process image")
            exit(1)
        }
        
        if let processedImageDir,
           let cgImage = ImageProcessor().cgImage(from: image) {
            writeImage(
                cgImage,
                to: processedImageDir,
                name: file.lastPathComponent)
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
