//
//  CSSStyleSheet.swift
//  CSSwiftUI
//
//  Created by Kevin Launay on 12/02/2026.
//

import SwiftUI

@Observable
public class CSSStyleSheet {
    private var classes: [String: String] = [:]
    
    public init() {}

    public func define(_ name: String, _ css: String) {
        let key = name.hasPrefix(".") ? String(name.dropFirst()) : name
        classes[key] = css
    }

    public func css(for name: String) -> String? {
        let key = name.hasPrefix(".") ? String(name.dropFirst()) : name
        return classes[key]
    }

    public func resolved(classes names: [String]) -> String {
        names.compactMap { css(for: $0) }.joined(separator: "; ")
    }

    // MARK: - CSS File Parsing

    /// Parse a raw CSS string and register all rules.
    public func parse(_ cssText: String) {
        // Strip /* ... */ comments
        var text = cssText
        while let start = text.range(of: "/*") {
            guard let end = text.range(of: "*/", range: start.upperBound..<text.endIndex) else { break }
            text.removeSubrange(start.lowerBound..<end.upperBound)
        }

        // Each "block" is everything before a closing brace
        for block in text.components(separatedBy: "}") {
            let parts = block.components(separatedBy: "{")
            guard parts.count == 2 else { continue }
            let selectors    = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let declarations = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !selectors.isEmpty, !declarations.isEmpty else { continue }

            // Support comma-separated selectors: ".hero, .banner { ... }"
            for selector in selectors.components(separatedBy: ",") {
                let name = selector.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { continue }
                define(name, declarations)
            }
        }
    }

    /// Load and parse a CSS file from the given bundle (defaults to .main).
    public func load(named filename: String, bundle: Bundle = .main) {
        let name = (filename as NSString).deletingPathExtension
        let ext  = (filename as NSString).pathExtension.isEmpty
                    ? "css"
                    : (filename as NSString).pathExtension
        guard
            let url  = bundle.url(forResource: name, withExtension: ext),
            let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            #if DEBUG
            print("CSSStyleSheet: could not load '\(filename)'")
            #endif
            return
        }
        parse(text)
    }
}
