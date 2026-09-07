//
//  CSSStyleSheet.swift
//  CSSwiftUI
//
//  Created by Kevin Launay on 12/02/2026.
//

import SwiftUI

/// An observable stylesheet that parses, registers, and resolves CSS rules for SwiftUI views.
@MainActor
@Observable
public class CSSStyleSheet {
    private var classes: [String: String] = [:]
    
    /// Creates an empty stylesheet.
    public init() {}

    /// Registers a CSS declaration for a given class name.
    /// - Parameters:
    ///   - name: The class name (with or without a leading period, e.g. `".button"` or `"button"`).
    ///   - css: The CSS declaration body (e.g. `"color: red; padding: 8px"`).
    public func define(_ name: String, _ css: String) {
        let key = name.hasPrefix(".") ? String(name.dropFirst()) : name
        classes[key] = css
    }

    /// Retrieves the registered CSS string for the specified class name, if defined.
    /// - Parameter name: The class name (with or without leading period).
    /// - Returns: The merged CSS string if present.
    public func css(for name: String) -> String? {
        let key = name.hasPrefix(".") ? String(name.dropFirst()) : name
        return classes[key]
    }

    /// Resolves a list of class names into a single merged CSS declaration string.
    /// - Parameter names: Array of class names to resolve in order.
    /// - Returns: Semicolon-separated CSS declaration string.
    public func resolved(classes names: [String]) -> String {
        names.compactMap { css(for: $0) }.joined(separator: "; ")
    }

    // MARK: - CSS File Parsing

    /// Parses a raw CSS stylesheet string, stripping comments and registering all class rules.
    /// - Parameter cssText: Raw CSS content.
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

    // MARK: - File Loading & Cache

    nonisolated(unsafe) private static var fileCache: [String: String] = [:]
    nonisolated private static let cacheLock = NSLock()

    /// Clears the in-memory CSS file cache.
    nonisolated public static func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        fileCache.removeAll()
    }

    nonisolated private static func getCachedCSS(for key: String) -> String? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return fileCache[key]
    }

    nonisolated private static func setCachedCSS(_ text: String, for key: String) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        fileCache[key] = text
    }

    nonisolated private static func resolveResource(named filename: String, in bundle: Bundle) -> (key: String, url: URL)? {
        let name = (filename as NSString).deletingPathExtension
        let ext  = (filename as NSString).pathExtension.isEmpty ? "css" : (filename as NSString).pathExtension
        guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
        let key = (bundle.bundleIdentifier ?? bundle.bundlePath) + "/" + name + "." + ext
        return (key, url)
    }

    /// Loads and parses a CSS file from the given bundle synchronously.
    /// - Parameters:
    ///   - filename: Name of the resource file (e.g. `"styles"` or `"styles.css"`).
    ///   - bundle: The resource bundle where the file is stored (defaults to `.main`).
    public func load(named filename: String, bundle: Bundle = .main) {
        guard let resource = Self.resolveResource(named: filename, in: bundle) else {
            #if DEBUG
            print("CSSStyleSheet: could not find '\(filename)'")
            #endif
            return
        }

        if let cached = Self.getCachedCSS(for: resource.key) {
            parse(cached)
            return
        }

        guard let text = try? String(contentsOf: resource.url, encoding: .utf8) else {
            #if DEBUG
            print("CSSStyleSheet: could not read '\(filename)'")
            #endif
            return
        }

        Self.setCachedCSS(text, for: resource.key)
        parse(text)
    }

    /// Loads and parses a CSS file from the given bundle asynchronously without blocking the main thread.
    /// - Parameters:
    ///   - filename: Name of the resource file (e.g. `"styles"` or `"styles.css"`).
    ///   - bundle: The resource bundle where the file is stored (defaults to `.main`).
    public func load(named filename: String, bundle: Bundle = .main) async {
        guard let resource = Self.resolveResource(named: filename, in: bundle) else {
            #if DEBUG
            print("CSSStyleSheet: could not find '\(filename)'")
            #endif
            return
        }

        if let cached = Self.getCachedCSS(for: resource.key) {
            parse(cached)
            return
        }

        let fileUrl = resource.url
        let text = await Task.detached(priority: .userInitiated) {
            try? String(contentsOf: fileUrl, encoding: .utf8)
        }.value

        guard let text else {
            #if DEBUG
            print("CSSStyleSheet: could not read '\(filename)'")
            #endif
            return
        }

        Self.setCachedCSS(text, for: resource.key)
        parse(text)
    }
}
