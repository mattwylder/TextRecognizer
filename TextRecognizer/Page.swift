//
//  Page.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import CoreGraphics
import Foundation
import StatKit

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
        let mean = mean(of: lines, variable: \.width)
        let standardDev = standardDeviation(of: lines, variable: \.width, from: .population)
        let oneStdDevBelow = mean - standardDev
        var output = ""
        for line in lines {
            output.append(line.text)
    
            if line.width < oneStdDevBelow {
                output.append("\n\t")
            } else {
                output.append(" ")
            }
        }
        return output
    }
}
