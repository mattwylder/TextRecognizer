//
//  ImageProcessor.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/19/23.
//
import CoreGraphics
import CoreImage
import Foundation

struct ImageProcessor {
    
    private let context = CIContext()
    
    func process(file: URL) -> CIImage? {
        let newURL = URL(string:"file://" + file.path)!
        let data = try! Data(contentsOf: newURL)
        let coreImage = CIImage(data: data)!
        
        let cropRect = CGRect(x: 178, y: 35, width: 1433, height: 1145)
        let cropped = coreImage.cropped(to: cropRect)
        return contrast(cropped)!
    }
    
    func contrast(_ image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls",
                              parameters: ["inputImage": image,
                                           "inputBrightness": 0.5,
                                           "inputContrast": 2,
                                           "inputSaturation": 0])
        return filter?.outputImage
    }
    
    func dilate(_ image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIMorphologyRectangleMaximum")
        filter?.setValue(image, forKey: kCIInputImageKey)
        return filter?.outputImage
    }
    
    func erode(_ image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIMorphologyRectangleMinimum")
        filter?.setValue(image, forKey: kCIInputImageKey)
        return filter?.outputImage
    }
    
    func sepiaFilter(_ image: CIImage, intensity: Double) -> CIImage? {
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputIntensityKey)
        return filter?.outputImage
    }
    
    func cgImage(from coreImage: CIImage) -> CGImage? {
        context.createCGImage(coreImage, from: coreImage.extent)
    }
}
