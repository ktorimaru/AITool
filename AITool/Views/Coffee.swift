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
                    Text("☕️")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    Text("AITool is Coffeeware")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Text("If you are using this software (especially if your being paid to do so) buy me some coffee!")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
//        .background(.green)
#if os(macOS)
        .frame(width: 400, height: 300)
#else
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
#endif
    }
}

struct Coffee_Previews: PreviewProvider {
    static var previews: some View {
        Coffee()
    }
}
