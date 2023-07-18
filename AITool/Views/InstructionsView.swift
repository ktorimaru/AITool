//
//  InstructionsView.swift
//  AITool
//
//  Created by Ken Torimaru on 7/17/23.
//

import SwiftUI

struct InstructionsView: View {
    var lineSpace: CGFloat = 4
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("AITool").font(.title)
                        .frame(alignment:.center)
                        .padding([.top], 8)
                    Text( "AITool currently implements the conversation element of OpenAI's large langage model API. This is the portion of the API used to implement applications like ChatGPT.")
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding([.bottom], lineSpace)
                        .font(.headline)
                    Text("The purpose of this tool is to help you interate through changes to your 'system' commands to perfect your script.")
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding([.bottom], lineSpace)
                    Text("Start by selecting an existing file or creating a new file using the 'New' button.")
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding([.bottom], lineSpace)
                    Text("If you are new to building a chat try the pizza example. Create the example and then iterate a chat. You can add user input by tapping ⊕ button below the last line of conversation. Choose the 'Testor' role to make your new line interact sequentially.")
                        .frame(maxWidth: .infinity, alignment:.leading)
                        .padding([.bottom], lineSpace)
                }.padding([.leading, .trailing], 8)
            }
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
