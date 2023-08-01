//
//  Styles.swift
//  AITool
//
//  Created by Ken Torimaru on 7/12/23.
//

import Foundation
import SwiftUI

struct ColorButtonStyle: ButtonStyle {
    var color: Color = .blue
    @Environment(\.isEnabled) var isEnabled
       
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .foregroundColor(.white)
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 5).fill(color))
        .compositingGroup()
        //.opacity(configuration.isPressed ? 0.5 : 1.0)
        .opacity(isEnabled ? 1.0 : 0.3)
        //.saturation(isEnabled ? 1 : 0)
    }
}

struct CheckboxStyle: ToggleStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
 
        return HStack {
 
            configuration.label
 
//            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 18, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}
