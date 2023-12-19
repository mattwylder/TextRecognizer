//
//  FileSystemTools.swift
//  TextRecognizer
//
//  Created by Matthew Wylder on 12/19/23.
//

import ImageIO
import Foundation

func getInputFilePaths(_ url: URL) -> [URL] {
    
    if url.isFileURL {
        return [url]
    }
    do {
        return try FileManager.default
            .contentsOfDirectory(atPath: url.path)
            .filter { !$0.hasPrefix(".") }
            .sorted(by: sortFileNames)
            .compactMap { url.appendingPathComponent($0) }
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

func writeImage(_ image: CGImage, to dir: URL, name: String) {
    if let writeURL = URL(string: "file://\(dir.appendingPathComponent(name))"),
       let dest = CGImageDestinationCreateWithURL(writeURL as CFURL,
                                                   kUTTypePNG, 1, nil) {
        CGImageDestinationAddImage(dest, image, nil)
        let _ = CGImageDestinationFinalize(dest)
    } else {
        print("skipping intermediate image save")
    }
}

func writeText(_ page: Page, to url: URL) {
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
