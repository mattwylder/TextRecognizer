//
//  Page.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/16/23.
//

import Foundation

class Page {
    struct Line {
        let text: String
        let rightMargin: Double
        let baseline: Double
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
