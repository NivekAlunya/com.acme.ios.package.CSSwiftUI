//
//  CSSwiftUI.swift
//  CSSwiftUI
//
//  Created by Kevin Launay on 12/02/2026.
//

import SwiftUI

/// A view modifier that loads a CSS stylesheet from a bundle and provides it to the view hierarchy via environment.
public struct CSSFileModifier: ViewModifier {
    @State private var sheet: CSSStyleSheet

    /// Initializes the modifier and immediately loads the CSS file to prevent unstyled content flashes.
    /// - Parameters:
    ///   - filename: The name of the CSS file (with or without `.css` extension).
    ///   - bundle: The resource bundle where the file is stored (defaults to `.main`).
    public init(named filename: String, bundle: Bundle = .main) {
        let s = CSSStyleSheet()
        s.load(named: filename, bundle: bundle)
        _sheet = State(initialValue: s)
    }

    public func body(content: Content) -> some View {
        content.environment(sheet)
    }
}

/// A view modifier that resolves one or more CSS class names against the environment stylesheet and applies their styles.
public struct CSSClassModifier: ViewModifier {
    @Environment(CSSStyleSheet.self) private var sheet: CSSStyleSheet?
    let classNames: [String]

    /// Initializes with space-delimited CSS class names (e.g. `"button primary active"`).
    /// - Parameter names: Space-separated CSS class names.
    public init(_ names: String) {
        classNames = names
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
    }

    public func body(content: Content) -> some View {
        let resolved = sheet?.resolved(classes: classNames) ?? ""
        return content.modifier(CssStyleModifier(resolved))
    }
}

private struct SmartImage: View {
    let name: String
    
    var body: some View {
        if isSystemImage(name) {
             Image(systemName: name)
                 .resizable()
        } else {
             Image(name)
                 .resizable()
        }
    }
    
    private func isSystemImage(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(systemName: name) != nil
        #elseif canImport(AppKit)
        if #available(macOS 11.0, *) {
            return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
        }
        return false
        #elseif os(watchOS)
        return name.contains(".")
        #else
        return false
        #endif
    }
}

/// A view modifier that applies styling parsed from a CSS declaration string or `CSSStyle` struct.
public struct CssStyleModifier: ViewModifier {
    public let css: CSSStyle

    /// Initializes with a CSS declaration string.
    /// - Parameter styleString: A semicolon-separated CSS property declaration string.
    public init(_ styleString: String) {
        self.css = CSSStyle(from: styleString)
    }

    /// Initializes directly with a pre-parsed `CSSStyle`.
    /// - Parameter css: The parsed CSS style.
    public init(_ css: CSSStyle) {
        self.css = css
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        let base = content
            .font(css.font)
            .foregroundStyle(css.foregroundColor ?? .primary)
            .padding(css.padding ?? EdgeInsets())
            .background(
                ZStack {
                    if let m = css.backgroundMaterial {
                        UnevenRoundedRectangle(cornerRadii: css.cornerRadius ?? RectangleCornerRadii())
                            .fill(m)
                    }
                    if let c = css.backgroundColor {
                        c
                    }
                    if let img = css.backgroundImage {
                         SmartImage(name: img)
                             .aspectRatio(contentMode: .fill)
                    }
                }
                .clipShape(UnevenRoundedRectangle(cornerRadii: css.cornerRadius ?? RectangleCornerRadii()))
            )
            .overlay(
                UnevenRoundedRectangle(cornerRadii: css.cornerRadius ?? RectangleCornerRadii())
                    .strokeBorder(css.borderColor ?? .clear, lineWidth: css.borderWidth?.top ?? 0)
            )
            .padding(css.margin ?? EdgeInsets())
            .underline(css.isUnderline, color: css.decorationColor)
            .strikethrough(css.isStrikethrough, color: css.decorationColor)
            .offset(css.offset ?? .zero)
            
        if let pos = css.position {
            base.position(pos)
        } else {
            base
        }
    }
}

/// Typealias providing conventional casing for `CssStyleModifier`.
public typealias CSSStyleModifier = CssStyleModifier

public extension View {
    /// Injects a CSS stylesheet loaded from the specified file into this view's environment.
    /// - Parameters:
    ///   - filename: The name of the CSS file.
    ///   - bundle: The bundle containing the file.
    func cssFile(named filename: String, bundle: Bundle = .main) -> some View {
        modifier(CSSFileModifier(named: filename, bundle: bundle))
    }
    
    /// Applies CSS class styles resolved from the ambient `CSSStyleSheet`.
    /// - Parameter names: One or more space-delimited class names.
    func cssClass(_ names: String) -> some View {
        modifier(CSSClassModifier(names))
    }
    
    /// Applies inline CSS styles to the view.
    /// - Parameter styleString: Semicolon-delimited CSS rules (e.g. `"color: red; font-weight: bold"`).
    func cssStyle(_ styleString: String) -> some View {
        modifier(CssStyleModifier(styleString))
    }
}
