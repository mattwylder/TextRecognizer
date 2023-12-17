//
//  Page.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import CoreGraphics
import Foundation

class Page {
    struct Line {
        let text: String
        let frame: CGRect
        let width: Double
        
        init(text: String, frame: CGRect) {
            self.text = text
            self.frame = frame
            self.width = frame.maxX - frame.minX
        }
    }
    
    var lines = [Line]()

    var content: String {
        var output = ""
        for line in lines {
            output.append(line.text)
        }
        return output
    }
}
