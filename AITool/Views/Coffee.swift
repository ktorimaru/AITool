//
//  Coffee.swift
//  AITool
//
//  Created by Ken Torimaru on 7/17/23.
//

import SwiftUI

struct Coffee: View {
    var body: some View {
        VStack {
            Group {
                HStack {
                    Text("☕️").font(.largeTitle)
                    Text("AITool is Coffeeware").font(.title)
                }
                Text("If you are using this software (especially if your being paid to do so) buy me some coffee!").font(.headline)
            }
            Spacer()
        }
        .padding()
#if os(macOS)
        .frame(width: 400, height: 300)
#endif

    }
}

struct Coffee_Previews: PreviewProvider {
    static var previews: some View {
        Coffee()
    }
}
