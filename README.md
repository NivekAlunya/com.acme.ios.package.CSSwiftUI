# com.acme.ios.package.CSSwiftUI

A powerful and lightweight library for styling SwiftUI views using CSS. Build responsive, maintainable UIs by separating your styling logic from your view logic, just like on the web.

CSSwiftUI allows you to parse standard CSS strings or files and apply them to your `View` hierarchy purely using SwiftUI modifiers. It bridges the gap between web design patterns and native iOS development, supporting dynamic styling, theme loading, and native `System` styling capabilities.

## Features

- **Full CSS Parsing**: Load standard CSS files (`.css`) or parse strings dynamically.
- **Class-Based Styling**: Apply styles via class names (`.cssClass("my-class")`), supporting composition.
- **Native Integration**: Seamlessly maps CSS properties to SwiftUI modifiers (e.g., `font-size` → `.font()`, `padding` → `.padding()`).
- **Advanced Layout**: Support for `padding`, `margin`, `border-radius` (uniform or per-corner), `offset`, and `position`.
- **System Colors**: Direct access to `UIColor` / `NSColor` semantic colors (e.g., `system-background`, `label`, `system-blue`).
- **Materials**: Use native blur effects with `background-material`.
- **Reactive**: Built with Swift Observation (`@Observable`) for instant updates.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/NivekAlunya/com.acme.ios.package.CSSwiftUI", from: "1.0.0")
]
```

## Usage

### 1. Load a CSS File

Use the `cssFile(named:)` modifier to load a CSS file (e.g., `styles.css`) from your bundle. This injects the stylesheet into the environment.

```swift
import SwiftUI
import CSSwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .cssFile(named: "styles") // Loads styles.css from the main bundle
        }
    }
}
```

**Example `styles.css`:**

```css
.title {
    font-size: 32;
    font-weight: bold;
    color: #333333;
}

.button {
    background-color: blue;
    color: white;
    font-size: 16;
}
```

### 2. Apply Classes

Use the `cssClass(_:)` modifier to apply styles defined in your stylesheet.

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .cssClass("title")
            
            Button("Click Me") {
                print("Clicked")
            }
            .cssClass("button")
        }
    }
}
```

### 3. Inline Styles

You can also apply inline styles directly using `cssStyle(_:)`.

```swift
Text("Custom Style")
    .cssStyle("color: red; font-size: 20; font-weight: bold;")
```

## Supported CSS Properties

CSSwiftUI supports a wide range of standard CSS properties, along with some platform-specific enhancements.

### Text & Fonts
- **`color`**: Text color. Supports named colors (`red`), hex (`#RRGGBB`), `rgb(r,g,b)`, and system colors (e.g., `label`, `system-blue`).
- **`font-size`**: Supports specific sizes (`16px`, `20`) or semantic text styles:
  - `large-title`, `title`, `title2`, `title3`, `headline`, `subheadline`, `body`, `callout`, `footnote`, `caption`
- **`font-weight`**: `100`–`900`, `thin`, `light`, `regular`, `bold`, `black`.
- **`font-style`**: `italic` or `normal`.
- **`text-decoration`**: `underline`, `line-through` (or both).
- **`text-decoration-color`**: Color of the decoration line.

### Layout & Spacing
- **`padding`**: Internal spacing. Supports 1, 2, or 4 values (Top/Right/Bottom/Left).
- **`margin`**: External spacing. Supports 1, 2, or 4 values.
- **`offset`**: Helper to offset the view (`x y`). E.g., `offset: 10 20`.
- **`position`**: Absolute-like positioning in parent context (`x y`). E.g., `position: 100 100`.

### Backgrounds & Borders
- **`background-color`**: View background color.
- **`background-image`**: Bundle image name or SF Symbol name (e.g., `star.fill`).
- **`background-material`**: SwiftUI Materials.
  - `ultra-thin-material`, `thin-material`, `regular-material`, `thick-material`, `ultra-thick-material`, `bar`.
- **`border-width`**: Width of the border stroke. Supports 1, 2, or 4 values.
- **`border-color`**: Color of the border.
- **`border-radius`**: Corner radius. Supports 1, 2, 3, or 4 values for individual corners (TL, TR, BR, BL).

### Values
- **Units**: Numbers are treated as points. `px` and `pt` suffixes are also supported and effectively treated as points.
- **System Colors**: Access `UIColor`/`NSColor` dynamic system colors using mapped names:
  - `system-background`, `secondary-system-background`, `tertiary-system-background`
  - `label`, `secondary-label`, `tertiary-label`
  - `separator`, `link`, `placeholder-text`
  - `system-blue`, `system-red`, `system-green`, etc.

## Requirements

- iOS 17.0+
- macOS 14.0+
- tvOS 17.0+
- watchOS 10.0+

## License

This library is licensed under the MIT License.
