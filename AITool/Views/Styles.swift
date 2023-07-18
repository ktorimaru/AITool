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
