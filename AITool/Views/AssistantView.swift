//
//  AssistantView.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/15/23.
//

import SwiftUI

struct AssistantView: View {
    var text: String
    var body: some View {
        HStack {
            Text("assistant")
                .font(.body)
                .padding([.leading, .trailing])
                .frame(width: 100, alignment: .leading)
            Text(text)
                .font(.body)
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AssistantView_Previews: PreviewProvider {
    static var previews: some View {
        AssistantView(text: "Test")
    }
}
