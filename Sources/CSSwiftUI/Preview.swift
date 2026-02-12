import SwiftUI

struct Preview: View {
    @State private var sheet: CSSStyleSheet = {
        let s = CSSStyleSheet()
        s.parse("""
        .bg-image-system {
            background-image: star.fill;
            background-color: #ddd; /* fallback or underlay */
            padding: 20px;
            color: clear; /* Hide text if desired, or overlay text */
            font-size: 20;
            border-radius: 10px;
        }

        .system-colors {
            background-color: system-background;
            color: syeren;
            padding: 20px;
            border-radius: 10px;
            border-width: 2px;
            border-color: system-blue;
        }

        .material-bg {
            background-material: regular-material;
            padding: 20px;
            border-radius: 15px;
            color: label;
        }

        .typography-demo {
            font-size: title;
            font-weight: bold;
            font-style: italic;
            text-decoration: underline line-through;
            text-decoration-color: red;
            color: system-indigo;
        }

        .complex-border {
            border-width: 4px 1px;
            border-color: system-orange;
            border-radius: 20px 0px 20px 0px;
            padding: 15px;
            background-color: system-gray6;
        }

        .spacing-demo {
            margin: 0 50px;
            padding: 20px 5px;
            background-color: system-mint;
            color: white;
            border-radius: 8px;
        }
        """)
        return s
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Background Image
                Text("                  ") // Placeholder spacing
                    .cssClass("bg-image-system")
                
                Divider()
                
                // System Colors
                Text("System Colors \n(systemBackground, label)")
                    .cssClass("system-colors")
                    .shadow(radius: 5)
                
                Divider()
                
                // Material Background
                ZStack {
                    Image(systemName: "checkerboard.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 100)
                        .foregroundStyle(.secondary)
                    
                    Text("Regular Material")
                        .cssClass("material-bg")
                }

                Divider()

                // Typography
                Text("Typography Demo")
                    .cssClass("typography-demo")

                Divider()

                // Complex Border
                Text("Complex Border \n(Radius: 20 0 20 0)")
                    .cssClass("complex-border")

                Divider()

                // Spacing
                Text("Spacing Demo \n(Margin: 0 50, Padding: 20 5)")
                    .cssClass("spacing-demo")
                    .border(.gray.opacity(0.3)) // To visualize margin
            }
        }
        .environment(sheet)
        .padding()
    }
}

#Preview {
    Preview()
}
