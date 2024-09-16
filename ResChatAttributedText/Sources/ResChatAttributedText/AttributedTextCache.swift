//
//  AttributedTextCache.swift
//  
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import ResChatProtocols

public class AttributedTextCache {
    
    // Static shared instance for singleton
    public static let shared = AttributedTextCache()
    
    // Private cache storage
    private var cache: [String: NSAttributedString] = [:]
    // FIXME: this is wrong,
    // because during streaming we are getting new messages for the same timestamp!!!
    
    // Private initializer to restrict instantiation
    private init() {}
    
    public func getAttributedText(for timestamp: String,
                                  messagePart: Int,
                                  isMessageComplete: Bool,
                                  text: String) -> NSAttributedString {
        
        let key = createCacheKeyFrom(timestamp: timestamp, messagePart: messagePart, isMessageComplete: isMessageComplete)
        
        if let cachedText = cache[key] {
            return cachedText
        }
        // Generate and cache the attributed string
        if let generatedText = Markdown2AttributedText.convertMarkdownToAttributedString(markdownText: text) {
            cache[key] = generatedText
            print("DBGGGG: generate attributed string for: \(key): `\(Markdown2AttributedText.summarizeString(text, upTo: 20))`")
            return generatedText
        } else {
            print("DBGGGG: error creating attributed string from: \(text)")
            return NSAttributedString(string: text)
        }
    }
    
    // Optionally clear the cache if needed
    public func clearCache() {
        cache.removeAll()
    }
}

private extension AttributedTextCache {
    
    func createCacheKeyFrom(timestamp: String, messagePart: Int, isMessageComplete: Bool) -> String {
        isMessageComplete
        ? timestamp
        : "\(timestamp)\(messagePart)"
    }
    
    /// Helper function to get the documents directory for file saving.
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

public extension AttributedTextCache {
    /// Converts the cache of attributed strings into a markdown file and saves it.
    /// - Parameter filename: The desired filename for the markdown file.
    func exportAttributedTextsToMarkdown(filename: String = "exported_attributed_texts.md") {
        let markdownStrings = cache.map { (timestamp, attributedText) -> String in
            return Markdown2AttributedText.convertAttributedTextToMarkdown(attributedText) // Convert each attributed string
        }
        
        // Combine all markdown strings
        let markdownContent = markdownStrings.joined(separator: "\n\n")
        
        // Save the markdown content to a file
        do {
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            try markdownContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Markdown file saved at: \(fileURL)")
        } catch {
            print("Error saving markdown file: \(error)")
        }
    }
    
    /// Exports the attributed strings in the cache to a file for inspection.
    /// - Parameter filename: The name of the file where attributed strings will be saved.
    func exportAttributedTextsForInspection(filename: String = "exported_attributed_texts.txt") {
        var exportedContent = ""
        
        // Iterate through the cache and extract attributed text with its attributes
        for (timestamp, attributedText) in cache {
            exportedContent += "Timestamp: \(timestamp)\n"
            exportedContent += inspectAttributedString(attributedText)
            exportedContent += "\n\n"
        }
        
        // Save the exported content to a file
        do {
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            try exportedContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Attributed strings file saved at: \(fileURL)")
        } catch {
            print("Error saving attributed strings file: \(error)")
        }
    }

    /// Helper function to inspect an attributed string and return its attributes in a readable format.
    /// - Parameter attributedText: The NSAttributedString to inspect.
    /// - Returns: A string representation of the attributed string's content and attributes.
    func inspectAttributedString(_ attributedText: NSAttributedString) -> String {
        var result = ""
        
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attributes, range, _ in
            let substring = attributedText.attributedSubstring(from: range).string
            result += "Text: \"\(substring)\"\n"
            result += "Attributes:\n"
            
            for (attribute, value) in attributes {
                result += "\t\(attribute): \(value)\n"
            }
            result += "------\n"
        }
        
        return result
    }
    
    func saveToDisk() {
        if !cache.isEmpty {
            exportAttributedTextsToMarkdown()
        }
    }
    
    func saveAttributedStringsToDisk() {
        if !cache.isEmpty {
            exportAttributedTextsForInspection()
        }
    }
}
