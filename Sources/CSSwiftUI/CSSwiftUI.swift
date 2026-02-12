// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI


public struct CSSFileModifier: ViewModifier {
    @State private var sheet = CSSStyleSheet()
    @State private var didLoad = false
    
    private let filename: String
    private let bundle: Bundle

    public init(named filename: String, bundle: Bundle = .main) {
        self.filename = filename
        self.bundle = bundle
    }

    public func body(content: Content) -> some View {
        content
            .task {
                // @State properties are MainActor-isolated, preventing race conditions
                guard !didLoad else { return }
                didLoad = true
                let s = CSSStyleSheet()
                s.load(named: filename, bundle: bundle)
                sheet = s
            }
            .environment(sheet)
    }
}
  

public struct CSSClassModifier: ViewModifier {
    @Environment(CSSStyleSheet.self) private var sheet
    let classNames: [String]

    public init(_ names: String) {
        classNames = names
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
    }

    public func body(content: Content) -> some View {
        let resolved = sheet.resolved(classes: classNames)
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
        // On watchOS, we can use SwiftUI's Image(systemName:) which works with SF Symbols
        // Since we can't check availability at runtime without UIKit/AppKit, we use a heuristic:
        // assume names with dots are SF Symbols (common pattern like "star.fill", "heart.fill")
        // Note: This may produce false positives for file names or other dotted strings
        return name.contains(".")
        #else
        return false
        #endif
    }
}


public struct CssStyleModifier: ViewModifier {
    let css: CSSStyle

    public init(_ styleString: String) {
        css = CSSStyle(from: styleString)
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

public extension View {
    func cssFile(named filename: String, bundle: Bundle = .main) -> some View {
        modifier(CSSFileModifier(named: filename, bundle: bundle))
    }
    
    func cssClass(_ names: String) -> some View {
        modifier(CSSClassModifier(names))
    }
    
    func cssStyle(_ styleString: String) -> some View {
        modifier(CssStyleModifier(styleString))
    }
}
