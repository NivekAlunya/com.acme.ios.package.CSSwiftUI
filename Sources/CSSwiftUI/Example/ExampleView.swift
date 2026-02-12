//
//  ExampleView.swift
//  CSSwiftUI
//
//  Created by Kevin Launay on 12/02/2026.
//

import SwiftUI

public struct ExampleView: View {
    @State private var sheet: CSSStyleSheet = {
        let s = CSSStyleSheet()
        s.parse("""
        .header {
            font-size: large-title;
            font-weight: bold;
            color: system-indigo;
            padding: 20px;
            text-decoration: underline;
            text-decoration-color: system-orange;
        }

        .card {
            background-color: system-background;
            padding: 20px;
            border-radius: 16px;
            margin: 10px 20px;
        }

        .card-title {
            font-size: title3;
            font-weight: semibold;
            color: label;
            margin: 0 0 10px 0;
        }

        .card-body {
            font-size: body;
            color: secondary-label;
        }

        .button-primary {
            background-color: system-blue;
            color: white;
            padding: 12px 24px;
            border-radius: 12px;
            font-weight: semibold;
            margin: 20px 0 0 0;
        }

        .material-box {
            background-material: regular-material;
            padding: 30px;
            border-radius: 20px 5px 20px 5px;
            border-width: 1px;
            border-color: separator;
            margin: 20px;
        }
        
        .complex-border {
            border-width: 4px 1px;
            border-color: system-orange;
            border-radius: 20px 0px 20px 0px;
            padding: 15px;
            background-color: system-gray6;
            font-size:title2; 
            font-weight: ultraLight;
        }
        """)
        return s
    }()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack {
                Text("CSSwiftUI Gallery")
                    .cssClass("header")
                
                // standard card
                VStack(alignment: .leading) {
                    Text("Standard Card")
                        .cssClass("card-title")
                    Text("This is a simple card component using system colors and standard styles defined in CSS.")
                        .cssClass("card-body")
                    
                    Button("Action") {
                        // action
                    }
                    .cssClass("button-primary")
                }
                .cssClass("card")
                .shadow(radius: 5)
                
                // Material example with background image
                ZStack {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200)
                        .foregroundStyle(.tertiary)
                        .padding()
                    
                    Text("Material Background")
                        .cssClass("material-box")
                }
                
                // Complex border example
                Text("Complex Border \n(Radius: 20 0 20 0)")
                    .cssClass("complex-border")
            }
            .padding()
        }
        .environment(sheet)
        .background(CSSStyle.systemColor(name: "systemGroupedBackground") ?? Color.gray.opacity(0.1))
    }
}

#Preview {
    ExampleView()
}
