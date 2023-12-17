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
        // create a line between the first and second to last line
        // determine a tolerance for the entire paragraph.
        // if the last line ends outside of that tolerance add a \n
        //
        // do something similar for line height.
        //
        // italics?
        //
        var output = ""
        for line in lines {
            output.append(line.text)
        }
        return output
    }
}
