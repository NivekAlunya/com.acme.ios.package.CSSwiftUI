//
//  CSSwiftUITests.swift
//  CSSwiftUITests
//
//  Created by Kevin Launay on 12/02/2026.
//

import Testing
import SwiftUI
@testable import CSSwiftUI

@Suite("CSSStyle Parsing Tests")
struct CSSStyleParsingTests {

    @Test("Parse 3-digit and 4-digit hex colors")
    func testHexShorthandColors() {
        let style3 = CSSStyle(from: "color: #F00; background-color: #0F0")
        #expect(style3.foregroundColor != nil)
        #expect(style3.backgroundColor != nil)

        let style4 = CSSStyle(from: "color: #F008")
        #expect(style4.foregroundColor != nil)
    }

    @Test("Parse 6-digit and 8-digit hex colors")
    func testFullHexColors() {
        let style6 = CSSStyle(from: "color: #FF5500; border-color: #00AAFF")
        #expect(style6.foregroundColor != nil)
        #expect(style6.borderColor != nil)

        let style8 = CSSStyle(from: "color: #FF5500AA")
        #expect(style8.foregroundColor != nil)
    }

    @Test("Parse rgb and rgba functional notation")
    func testRGBAndRGBAColors() {
        let rgbStyle = CSSStyle(from: "color: rgb(255, 128, 0)")
        #expect(rgbStyle.foregroundColor != nil)

        let rgbaStyle = CSSStyle(from: "color: rgba(255, 128, 0, 0.75)")
        #expect(rgbaStyle.foregroundColor != nil)
    }

    @Test("Parse transparent and clear colors")
    func testTransparentColors() {
        let clearStyle = CSSStyle(from: "background-color: clear; border-color: transparent")
        #expect(clearStyle.backgroundColor == .clear)
        #expect(clearStyle.borderColor == .clear)
    }

    @Test("Parse camelCase and hyphenated system colors")
    func testSystemColors() {
        let styleUpper = CSSStyle(from: "background-color: SystemBackground; color: SecondaryLabel")
        #expect(styleUpper.backgroundColor != nil)
        #expect(styleUpper.foregroundColor != nil)

        let styleLower = CSSStyle(from: "background-color: systemBackground; color: secondaryLabel")
        #expect(styleLower.backgroundColor != nil)
        #expect(styleLower.foregroundColor != nil)

        let styleHyphen = CSSStyle(from: "background-color: system-background; color: secondary-label")
        #expect(styleHyphen.backgroundColor != nil)
        #expect(styleHyphen.foregroundColor != nil)
    }

    @Test("Parse font size and weight")
    func testFontSizeAndWeight() {
        let fixedStyle = CSSStyle(from: "font-size: 22px; font-weight: bold")
        #expect(fixedStyle.fontSize == .fixed(22))
        #expect(fixedStyle.fontWeight == .bold)
        #expect(fixedStyle.font != nil)

        let semanticStyle = CSSStyle(from: "font-size: large-title; font-style: italic")
        #expect(semanticStyle.fontSize == .textStyle(.largeTitle))
        #expect(semanticStyle.isItalic == true)
        #expect(semanticStyle.font != nil)
    }

    @Test("Parse box shorthand padding and margin")
    func testBoxShorthand() {
        let single = CSSStyle(from: "padding: 12px")
        #expect(single.padding?.top == 12)
        #expect(single.padding?.leading == 12)
        #expect(single.padding?.bottom == 12)
        #expect(single.padding?.trailing == 12)

        let dual = CSSStyle(from: "margin: 8px 16px")
        #expect(dual.margin?.top == 8)
        #expect(dual.margin?.bottom == 8)
        #expect(dual.margin?.leading == 16)
        #expect(dual.margin?.trailing == 16)

        let quad = CSSStyle(from: "padding: 1px 2px 3px 4px")
        #expect(quad.padding?.top == 1)
        #expect(quad.padding?.trailing == 2)
        #expect(quad.padding?.bottom == 3)
        #expect(quad.padding?.leading == 4)
    }

    @Test("Parse corner radius shorthand")
    func testCornerRadius() {
        let uniform = CSSStyle(from: "border-radius: 10px")
        #expect(uniform.cornerRadius?.topLeading == 10)
        #expect(uniform.cornerRadius?.bottomTrailing == 10)

        let varied = CSSStyle(from: "border-radius: 4px 8px 12px 16px")
        #expect(varied.cornerRadius?.topLeading == 4)
        #expect(varied.cornerRadius?.topTrailing == 8)
        #expect(varied.cornerRadius?.bottomTrailing == 12)
        #expect(varied.cornerRadius?.bottomLeading == 16)
    }

    @Test("Parse text decorations")
    func testTextDecoration() {
        let style = CSSStyle(from: "text-decoration: underline line-through; text-decoration-color: red")
        #expect(style.isUnderline == true)
        #expect(style.isStrikethrough == true)
        #expect(style.decorationColor == .red)
    }
}

@Suite("CSSStyleSheet Tests")
struct CSSStyleSheetTests {

    @Test("Define and resolve stylesheet classes")
    func testDefineAndResolve() {
        let sheet = CSSStyleSheet()
        sheet.define("btn", "color: red; padding: 10px")
        sheet.define(".primary", "background-color: blue")

        #expect(sheet.css(for: "btn") == "color: red; padding: 10px")
        #expect(sheet.css(for: "primary") == "background-color: blue")

        let combined = sheet.resolved(classes: ["btn", "primary"])
        #expect(combined == "color: red; padding: 10px; background-color: blue")
    }

    @Test("Overwriting definitions replaces previous declaration for the same name")
    func testOverwriteDefinition() {
        let sheet = CSSStyleSheet()
        sheet.define("card", "color: white")
        sheet.define("card", "background-color: black")

        let resolved = sheet.css(for: "card")
        #expect(resolved == "background-color: black")
    }

    @Test("Parse raw CSS block with comments and multiple selectors")
    func testParseRawCSS() {
        let sheet = CSSStyleSheet()
        let cssText = """
        /* Main heading styles */
        .title, .heading {
            font-size: 24px;
            font-weight: bold;
        }
        /* Container */
        .box {
            padding: 16px;
            border-radius: 8px;
        }
        """
        sheet.parse(cssText)

        #expect(sheet.css(for: "title")?.contains("font-size: 24px") == true)
        #expect(sheet.css(for: "heading")?.contains("font-weight: bold") == true)
        #expect(sheet.css(for: "box")?.contains("border-radius: 8px") == true)
    }
}
