//
//  SetKeyView.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 7/14/23.
//

import SwiftUI

struct SetKeyView: View {
    @EnvironmentObject var model: Model
    var body: some View {
        Text("**OpenAI Key**").padding(8)
        Divider()
        Text("A developer key from OpenAI is required for this app to function.\nPlease enter it below.")
            .padding(8)
            .foregroundColor(.black)
        TextField("OpenAI Key:", text: $model.openAIKey, prompt: Text("OpenAI Key"))
            .padding([.leading, .trailing], 8)
            .foregroundColor(.black)
        Text("You can create test scripts without a key but cannot run them.")
            .padding([.leading, .trailing],8)
            .foregroundColor(.black)
        HStack {
            Button("Cancel") {
                model.showKeyView = false
            }
            .buttonStyle(ColorButtonStyle())
            Button("Save") {
                model.defaults.setValue(model.openAIKey, forKey: "openai")
                model.showKeyView = false
            }
            .buttonStyle(ColorButtonStyle())
        }
#if os(macOS)
        .padding(8)
        .frame(width: 400, height: 300)
#else
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
#endif
    }
}

struct SetKeyView_Previews: PreviewProvider {
    static var previews: some View {
        SetKeyView()
    }
}
