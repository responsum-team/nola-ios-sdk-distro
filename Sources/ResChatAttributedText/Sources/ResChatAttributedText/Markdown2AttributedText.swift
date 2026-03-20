//
//  File.swift
//  
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import Down

#if canImport(UIKit)
import UIKit
public typealias FontType = UIFont
public typealias ColorType = UIColor
extension UIColor {
    func toCSSColor() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        // resolvedColor ensures the dynamic color is resolved for the current trait collection,
        // and converting to sRGB guarantees getRed succeeds (it can fail on grayscale/P3 colors).
        let resolved = self.resolvedColor(with: UITraitCollection.current)
        if let srgb = resolved.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) {
            let components = srgb.components ?? []
            red = components.count > 0 ? components[0] : 0
            green = components.count > 1 ? components[1] : 0
            blue = components.count > 2 ? components[2] : 0
            alpha = components.count > 3 ? components[3] : 1
        } else {
            // Fallback: try getRed directly
            resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        return String(format: "rgba(%d, %d, %d, %.2f)", Int(red * 255), Int(green * 255), Int(blue * 255), alpha)
    }
}
#elseif canImport(AppKit)
import AppKit
public typealias FontType = NSFont
public typealias ColorType = NSColor

extension NSColor {
    func toCSSColor() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        // Convert to sRGB first to ensure getRed succeeds (fails on catalog/pattern colors)
        if let rgbColor = usingColorSpace(.sRGB) {
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        } else if let deviceRGB = usingColorSpace(.deviceRGB) {
            deviceRGB.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        // If both conversions failed, defaults stay at rgba(0,0,0,0) — use black as fallback
        if alpha == 0 && red == 0 && green == 0 && blue == 0 {
            alpha = 1.0 // Ensure text is never transparent
        }
        return String(format: "rgba(%d, %d, %d, %.2f)", Int(red * 255), Int(green * 255), Int(blue * 255), alpha)
    }
}
#endif


struct Markdown2AttributedText {
    
    /// Converts an `NSAttributedString` to markdown using Down.
    static func convertAttributedTextToMarkdown(_ attributedText: NSAttributedString) -> String {
        guard let downAttributedString = try? Down(markdownString: attributedText.string).toAttributedString() else {
            return attributedText.string // Fall back to plain text if Down conversion fails
        }
        return downAttributedString.string // Extract and return the raw markdown string
    }
    
    /// Converts markdown to  `NSAttributedString` using Down.
    static func convertMarkdownToAttributedString(markdownText: String) -> NSAttributedString? {
        convertMarkdownToAttributedStringStyled(markdownText: markdownText)
    }
    
    static func summarizeString(_ input: String?, upTo count: Int) -> String? {
        guard let input = input else { return nil }
        let prefixString = String(input.prefix(count))
        let remainingCharacters = input.count - prefixString.count
        let summary = "\(prefixString) (+ \(remainingCharacters) characters)"
        return summary
    }
    
}

private extension Markdown2AttributedText {
    static func convertMarkdownToAttributedStringDefault(markdownText: String) -> NSAttributedString? {
        do {
            let down = Down(markdownString: markdownText)
            let attributedString = try down.toAttributedString(.default, stylesheet: "body { font-size: 16px; }")
            return attributedString
        } catch {
            print("Error converting markdown to attributed string: \(error)")
            return nil
        }
    }
    
    static func convertMarkdownToAttributedStringStyled(markdownText: String) -> NSAttributedString? {
        do {
            let down = Down(markdownString: markdownText)
            
            #if os(iOS)
            let fontSize = FontType.preferredFont(forTextStyle: .body).pointSize
            let textColor = ColorType.label.toCSSColor()
            #elseif os(macOS)
            let fontSize = FontType.systemFontSize // macOS doesn't have preferredFont like iOS
            let textColor = ColorType.textColor.toCSSColor() // Use textColor for label equivalent on macOS
            #endif
            
            let stylesheet = """
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                font-size: \(fontSize)px;
                color: \(textColor);
            }
            """
            let attributedString = try down.toAttributedString(.default, stylesheet: stylesheet)
            return attributedString
        } catch {
            print("Error converting markdown to attributed string: \(error)")
            return nil
        }
    }
}
