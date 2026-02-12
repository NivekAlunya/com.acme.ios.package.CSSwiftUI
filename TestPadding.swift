import Foundation
import CoreGraphics

// Mocking Color and Font for standalone testing
struct Color {}
struct Font { 
    enum Weight { case bold }
    enum TextStyle { case body }
}

public struct CSSStyle {
    public var padding: CGFloat?
    public var margin: CGFloat?

    static func parseSize(_ value: String) -> CGFloat? {
        for suffix in ["px", "pt"] where value.hasSuffix(suffix) {
            let n = value.dropLast(suffix.count).trimmingCharacters(in: .whitespaces)
            if let d = Double(n) { return CGFloat(d) }
        }
        return Double(value).map { CGFloat($0) }
    }

    public init(from cssString: String) {
        // Use components(separatedBy:) or split correctly
        let declarations = cssString.components(separatedBy: ";")
        
        for declaration in declarations {
            let parts = declaration
                .split(separator: ":", maxSplits: 1)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            guard parts.count == 2 else { continue }
            let property = parts[0].lowercased()
            let value    = parts[1].lowercased()
            
            print("Property: '\(property)', Value: '\(value)'")
            
            switch property {
            case "padding":
                padding = Self.parseSize(value)
                print("  -> Parsed padding: \(String(describing: padding))")
            case "margin":
                margin = Self.parseSize(value)
                print("  -> Parsed margin: \(String(describing: margin))")
            default: break
            }
        }
    }
}

let css = """
            background-color: blue;
            color: white;
            font-size: 16;
            padding: 100px;
            margin: 5px;
"""

print("--- Test Start ---")
let style = CSSStyle(from: css)
print("--- Test End ---")
print("Final Padding: \(String(describing: style.padding))")
print("Final Margin: \(String(describing: style.margin))")
