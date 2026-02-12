//
//  CSSStyle.swift
//  CSSwiftUI
//
//  Created by Kevin Launay on 12/02/2026.
//
import SwiftUI

public struct CSSStyle {

    public enum FontSize {
        case textStyle(Font.TextStyle)
        case fixed(CGFloat)
    }

    public var foregroundColor: Color?
    public var backgroundColor: Color?
    public var fontSize: FontSize?
    public var fontWeight: Font.Weight?
    public var padding: EdgeInsets?
    public var margin: EdgeInsets?
    public var cornerRadius: RectangleCornerRadii?
    public var borderWidth: EdgeInsets?
    public var borderColor: Color?
    public var backgroundImage: String?
    public var backgroundMaterial: Material?
    public var offset: CGSize?
    public var position: CGPoint?
    public var isItalic: Bool = false
    public var isUnderline: Bool = false
    public var isStrikethrough: Bool = false
    public var decorationColor: Color? = nil

    public var font: Font? {
        guard fontSize != nil || fontWeight != nil || isItalic else { return nil }
        var base: Font
        switch fontSize {
        case .textStyle(let style): base = Self.font(for: style)
        case .fixed(let size):      base = .system(size: size)
        case nil:                   base = .body
        }
        if let w = fontWeight { base = base.weight(w) }
        if isItalic { base = base.italic() }
        return base
    }

    public init(from cssString: String) {
        for declaration in cssString.split(separator: ";") {
            let parts = declaration
                .split(separator: ":", maxSplits: 1)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard parts.count == 2 else { continue }
            let property = parts[0].lowercased()
            let value    = parts[1].lowercased()
            switch property {
            case "color":                foregroundColor = Self.parseColor(value)
            case "background-color":     backgroundColor = Self.parseColor(value)
            case "font-size":            fontSize        = Self.parseFontSize(value)
            case "font-weight":          fontWeight      = Self.parseFontWeight(value)
            case "padding":              padding         = Self.parseBox(value)
            case "margin":               margin          = Self.parseBox(value)
            case "border-radius":        cornerRadius    = Self.parseCornerRadii(value)
            case "border-width":         borderWidth     = Self.parseBox(value)
            case "border-color":         borderColor     = Self.parseColor(value)
            case "background-image":     backgroundImage = value.trimmingCharacters(in: .whitespacesAndNewlines)
            case "background-material":  backgroundMaterial = Self.parseMaterial(value)
            case "offset":               offset          = Self.parseOffset(value)
            case "position":             position        = Self.parsePosition(value)
            case "font-style":           isItalic        = (value == "italic")
            case "text-decoration":
                // supports "underline", "line-through", or combined "underline line-through"
                isUnderline      = value.contains("underline")
                isStrikethrough  = value.contains("line-through")
            case "text-decoration-color": decorationColor = Self.parseColor(value)
            default: break
            }
        }
    }

    // MARK: TextStyle → Font

    static func font(for style: Font.TextStyle) -> Font {
        switch style {
        case .largeTitle:  return .largeTitle
        case .title:       return .title
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption
        case .caption2:    return .caption2
        default:           return .body
        }
    }

    // MARK: Size

    static func parseSize(_ value: String) -> CGFloat? {
        for suffix in ["px", "pt"] where value.hasSuffix(suffix) {
            let n = value.dropLast(suffix.count).trimmingCharacters(in: .whitespaces)
            if let d = Double(n) { return CGFloat(d) }
        }
        return Double(value).map { CGFloat($0) }
    }

    static func parseBox(_ value: String) -> EdgeInsets? {
        let parts = value.split(separator: " ").map { String($0) }
        let values = parts.compactMap { parseSize($0) }
        
        // CSS: top right bottom left
        // SwiftUI: top leading bottom trailing
        // We map right -> trailing, left -> leading
        
        switch values.count {
        case 1:
            let v = values[0]
            return EdgeInsets(top: v, leading: v, bottom: v, trailing: v)
        case 2:
            let tb = values[0]
            let lr = values[1]
            return EdgeInsets(top: tb, leading: lr, bottom: tb, trailing: lr)
        case 3:
            let t = values[0]
            let lr = values[1]
            let b = values[2]
            return EdgeInsets(top: t, leading: lr, bottom: b, trailing: lr)
        case 4:
            let t = values[0]
            let r = values[1]
            let b = values[2]
            let l = values[3]
            return EdgeInsets(top: t, leading: l, bottom: b, trailing: r)
        default:
            return nil
        }
    }

    // MARK: Corner Radius

    static func parseCornerRadii(_ value: String) -> RectangleCornerRadii? {
        let parts = value.split(separator: " ").map { String($0) }
        let values = parts.compactMap { parseSize($0) }
        
        // CSS Order: Top-Left, Top-Right, Bottom-Right, Bottom-Left
        // SwiftUI Use: topLeading, topTrailing, bottomTrailing, bottomLeading
        
        switch values.count {
        case 1:
            // All same
            let v = values[0]
            return RectangleCornerRadii(topLeading: v, bottomLeading: v, bottomTrailing: v, topTrailing: v)
        case 2:
            // TL/BR and TR/BL
            let tl_br = values[0]
            let tr_bl = values[1]
            return RectangleCornerRadii(topLeading: tl_br, bottomLeading: tr_bl, bottomTrailing: tl_br, topTrailing: tr_bl)
        case 3:
            // TL, TR/BL, BR
            let tl = values[0]
            let tr_bl = values[1]
            let br = values[2]
            return RectangleCornerRadii(topLeading: tl, bottomLeading: tr_bl, bottomTrailing: br, topTrailing: tr_bl)
        case 4:
            // TL, TR, BR, BL
            let tl = values[0]
            let tr = values[1]
            let br = values[2]
            let bl = values[3]
            return RectangleCornerRadii(topLeading: tl, bottomLeading: bl, bottomTrailing: br, topTrailing: tr)
        default:
            return nil
        }
    }

    // MARK: Material

    static func parseMaterial(_ value: String) -> Material? {
        switch value {
        case "ultra-thin-material", "ultrathinmaterial": return .ultraThinMaterial
        case "thin-material", "thinmaterial":            return .thinMaterial
        case "regular-material", "regularmaterial":      return .regularMaterial
        case "thick-material", "thickmaterial":          return .thickMaterial
        case "ultra-thick-material", "ultrathickmaterial": return .ultraThickMaterial
        case "bar": return .bar
        default: return nil
        }
    }

    // MARK: Offset / Position

    static func parseOffset(_ value: String) -> CGSize? {
        // x y
        let parts = value.split(separator: " ").map { String($0) }
        let values = parts.compactMap { parseSize($0) }
        guard values.count == 2 else { return nil }
        return CGSize(width: values[0], height: values[1])
    }

    static func parsePosition(_ value: String) -> CGPoint? {
        // x y
        let parts = value.split(separator: " ").map { String($0) }
        let values = parts.compactMap { parseSize($0) }
        guard values.count == 2 else { return nil }
        return CGPoint(x: values[0], y: values[1])
    }

    // MARK: Font size

    static func parseFontSize(_ value: String) -> FontSize? {
        switch value {
        case "large-title":          return .textStyle(.largeTitle)
        case "title", "title1":      return .textStyle(.title)
        case "title2":               return .textStyle(.title2)
        case "title3":               return .textStyle(.title3)
        case "headline":             return .textStyle(.headline)
        case "subheadline":          return .textStyle(.subheadline)
        case "body":                 return .textStyle(.body)
        case "callout":              return .textStyle(.callout)
        case "footnote":             return .textStyle(.footnote)
        case "caption", "caption1":  return .textStyle(.caption)
        case "caption2":             return .textStyle(.caption2)
        default: break
        }
        for suffix in ["px", "pt"] where value.hasSuffix(suffix) {
            let n = value.dropLast(suffix.count).trimmingCharacters(in: .whitespaces)
            if let d = Double(n) { return .fixed(CGFloat(d)) }
        }
        switch value {
        case "x-small":          return .fixed(10)
        case "small":            return .fixed(12)
        case "medium", "normal": return .fixed(16)
        case "large":            return .fixed(20)
        case "x-large":          return .fixed(24)
        case "xx-large":         return .fixed(28)
        default: break
        }
        return Double(value).map { .fixed(CGFloat($0)) }
    }

    // MARK: Font weight

    static func parseFontWeight(_ value: String) -> Font.Weight? {
        switch value {
        case "100", "thin":                      return .thin
        case "200", "ultralight", "extra-light": return .ultraLight
        case "300", "light":                     return .light
        case "400", "normal", "regular":         return .regular
        case "500", "medium":                    return .medium
        case "600", "semibold", "semi-bold":     return .semibold
        case "700", "bold":                      return .bold
        case "800", "heavy", "extrabold":        return .heavy
        case "900", "black":                     return .black
        default:                                 return nil
        }
    }

    // MARK: Color

    static func parseColor(_ value: String) -> Color? {
        switch value {
        case "red":           return .red
        case "blue":          return .blue
        case "green":         return .green
        case "black":         return .black
        case "white":         return .white
        case "gray", "grey":  return .gray
        case "orange":        return .orange
        case "yellow":        return .yellow
        case "pink":          return .pink
        case "purple":        return .purple
        case "cyan":          return .cyan
        case "mint":          return .mint
        case "teal":          return .teal
        case "indigo":        return .indigo
        case "primary":       return .primary
        case "secondary":     return .secondary
        case "systembackground", "system-background": return systemColor(name: "systemBackground")
        case "secondarysystembackground", "secondary-system-background": return systemColor(name: "secondarySystemBackground")
        case "tertiarysystembackground", "tertiary-system-background": return systemColor(name: "tertiarySystemBackground")
        case "systemgroupedbackground", "system-grouped-background": return systemColor(name: "systemGroupedBackground")
        case "secondarysystemgroupedbackground", "secondary-system-grouped-background": return systemColor(name: "secondarySystemGroupedBackground")
        case "tertiarysystemgroupedbackground", "tertiary-system-grouped-background": return systemColor(name: "tertiarySystemGroupedBackground")
        case "label":         return systemColor(name: "label")
        case "secondarylabel", "secondary-label": return systemColor(name: "secondaryLabel")
        case "tertiarylabel", "tertiary-label":   return systemColor(name: "tertiaryLabel")
        case "quaternarylabel", "quaternary-label": return systemColor(name: "quaternaryLabel")
        case "link":          return systemColor(name: "link")
        case "placeholdertext", "placeholder-text": return systemColor(name: "placeholderText")
        case "separator":     return systemColor(name: "separator")
        case "opaqueseparator", "opaque-separator": return systemColor(name: "opaqueSeparator")
        case "systemblue", "system-blue":       return systemColor(name: "systemBlue")
        case "systemgreen", "system-green":     return systemColor(name: "systemGreen")
        case "systemindigo", "system-indigo":   return systemColor(name: "systemIndigo")
        case "systemorange", "system-orange":   return systemColor(name: "systemOrange")
        case "systempink", "system-pink":       return systemColor(name: "systemPink")
        case "systempurple", "system-purple":   return systemColor(name: "systemPurple")
        case "systemred", "system-red":         return systemColor(name: "systemRed")
        case "systemteal", "system-teal":       return systemColor(name: "systemTeal")
        case "systemyellow", "system-yellow":   return systemColor(name: "systemYellow")
        case "systemgray", "system-gray":       return systemColor(name: "systemGray")
        case "systemgray2", "system-gray2":     return systemColor(name: "systemGray2")
        case "systemgray3", "system-gray3":     return systemColor(name: "systemGray3")
        case "systemgray4", "system-gray4":     return systemColor(name: "systemGray4")
        case "systemgray5", "system-gray5":     return systemColor(name: "systemGray5")
        case "systemgray6", "system-gray6":     return systemColor(name: "systemGray6")
        default:
            if value.hasPrefix("#")    { return parseHexColor(value) }
            if value.hasPrefix("rgb(") { return parseRGBColor(value) }
            return nil
        }
    }

    static func parseHexColor(_ hex: String) -> Color? {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        var rgb: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&rgb) else { return nil }
        switch str.count {
        case 6:
            return Color(
                red:   Double((rgb & 0xFF0000) >> 16) / 255,
                green: Double((rgb & 0x00FF00) >>  8) / 255,
                blue:  Double( rgb & 0x0000FF        ) / 255
            )
        case 8:
            return Color(
                red:     Double((rgb & 0xFF000000) >> 24) / 255,
                green:   Double((rgb & 0x00FF0000) >> 16) / 255,
                blue:    Double((rgb & 0x0000FF00) >>  8) / 255,
                opacity: Double( rgb & 0x000000FF        ) / 255
            )
        default: return nil
        }
    }

    static func parseRGBColor(_ value: String) -> Color? {
        let nums = value
            .replacingOccurrences(of: "rgb(", with: "")
            .replacingOccurrences(of: ")",    with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard nums.count == 3 else { return nil }
        return Color(red: nums[0]/255, green: nums[1]/255, blue: nums[2]/255)
    }

    static func systemColor(name: String) -> Color? {
        #if canImport(UIKit)
        switch name {
        case "systemBackground": return Color(uiColor: .systemBackground)
        case "secondarySystemBackground": return Color(uiColor: .secondarySystemBackground)
        case "tertiarySystemBackground": return Color(uiColor: .tertiarySystemBackground)
        case "systemGroupedBackground": return Color(uiColor: .systemGroupedBackground)
        case "secondarySystemGroupedBackground": return Color(uiColor: .secondarySystemGroupedBackground)
        case "tertiarySystemGroupedBackground": return Color(uiColor: .tertiarySystemGroupedBackground)
        case "label": return Color(uiColor: .label)
        case "secondaryLabel": return Color(uiColor: .secondaryLabel)
        case "tertiaryLabel": return Color(uiColor: .tertiaryLabel)
        case "quaternaryLabel": return Color(uiColor: .quaternaryLabel)
        case "link": return Color(uiColor: .link)
        case "placeholderText": return Color(uiColor: .placeholderText)
        case "separator": return Color(uiColor: .separator)
        case "opaqueSeparator": return Color(uiColor: .opaqueSeparator)
        case "systemBlue": return Color(uiColor: .systemBlue)
        case "systemGreen": return Color(uiColor: .systemGreen)
        case "systemIndigo": return Color(uiColor: .systemIndigo)
        case "systemOrange": return Color(uiColor: .systemOrange)
        case "systemPink": return Color(uiColor: .systemPink)
        case "systemPurple": return Color(uiColor: .systemPurple)
        case "systemRed": return Color(uiColor: .systemRed)
        case "systemTeal": return Color(uiColor: .systemTeal)
        case "systemYellow": return Color(uiColor: .systemYellow)
        case "systemGray": return Color(uiColor: .systemGray)
        case "systemGray2": return Color(uiColor: .systemGray2)
        case "systemGray3": return Color(uiColor: .systemGray3)
        case "systemGray4": return Color(uiColor: .systemGray4)
        case "systemGray5": return Color(uiColor: .systemGray5)
        case "systemGray6": return Color(uiColor: .systemGray6)
        default: return nil
        }
        #elseif canImport(AppKit)
        // Map to NSColor equivalents where possible, otherwise fallback
        switch name {
        case "systemBackground": return Color(nsColor: .windowBackgroundColor)
        case "secondarySystemBackground": return Color(nsColor: .controlBackgroundColor)
        case "tertiarySystemBackground": return Color(nsColor: .textBackgroundColor) // Approximate
        case "label": return Color(nsColor: .labelColor)
        case "secondaryLabel": return Color(nsColor: .secondaryLabelColor)
        case "tertiaryLabel": return Color(nsColor: .tertiaryLabelColor)
        case "quaternaryLabel": return Color(nsColor: .quaternaryLabelColor)
        case "link": return Color(nsColor: .linkColor)
        case "placeholderText": return Color(nsColor: .placeholderTextColor)
        case "separator": return Color(nsColor: .separatorColor)
        case "opaqueSeparator": return Color(nsColor: .gridColor)
        case "systemBlue": return Color(nsColor: .systemBlue)
        case "systemGreen": return Color(nsColor: .systemGreen)
        case "systemIndigo": return Color(nsColor: .systemIndigo)
        case "systemOrange": return Color(nsColor: .systemOrange)
        case "systemPink": return Color(nsColor: .systemPink)
        case "systemPurple": return Color(nsColor: .systemPurple)
        case "systemRed": return Color(nsColor: .systemRed)
        case "systemTeal": return Color(nsColor: .systemTeal)
        case "systemYellow": return Color(nsColor: .systemYellow)
        case "systemGray": return Color(nsColor: .systemGray)
        default: return nil
        }
        #else
        return nil
        #endif
    }
}
