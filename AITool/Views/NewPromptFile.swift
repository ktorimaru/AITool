//
//  NewPromptFile.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/8/23.
//

import SwiftUI

struct NewPromptFile: View {
    @EnvironmentObject var model: Model
    @State var fileName: String = ""
    @State var selection: Int = 0
    private let list = ["Simple Chat", "Blank", "Pizza Example"]
    var body: some View {
        VStack(alignment: .center, spacing: 0 ) {
            Form {
            Text("Create a New Prompt File")
                .font(.headline)
                .padding([.top, .leading, .trailing])
            Divider().padding([.bottom, .leading, .trailing])
            
                Picker("Prompt Type", selection: self.$selection) {
                    Text("Simple Chat").tag(0)
                    Text("Blank").tag(1)
                    Text("Pizza Example").tag(2)
                }
                //.frame(width: 300)

                Text("Selection: \(list[selection])")
                HStack {
                    TextField("File name:", text: $fileName, prompt: Text("File name"))
                    Text(".json")
                }
                Spacer()
                HStack {
                    Spacer()
                    Button("Create") {
                        print("Create")
                        do {
                            if model.selected != nil {
                                try model.currentPromptFile.saveFile()
                            }
                        } catch {
                            print("\(#function) Error: \(error.localizedDescription)")
                        }

                        DispatchQueue.main.async {
                            switch selection {
                            case 0:
                                _ = model.simplePromptFile(fileName: fileName)
                            case 1:
                                _ = model.blankPromptFile(fileName: fileName)
                            case 2:
                                _ = model.pizzaPromptFile(fileName: fileName)
                            default:
                                print("Should never get here")
                            }
                            //model.readDirectory()
//                            model.selectedFile.name = "\(fileName).json"
                            model.newFileIsPresented = false
                        }
                            
                    }.disabled(fileName == "")
                    Button("Cancel") {
                        model.newFileIsPresented = false
                        print("Cancel")
                    }

                }
            }
#if os(macOS)
            .pickerStyle(.radioGroup)
#endif
            .padding()
            Spacer()
        }
#if os(macOS)
        .frame(width: 400, height: 300)
#endif
    }
}

struct NewPromptFile_Previews: PreviewProvider {
    static var previews: some View {
        NewPromptFile()
            
    }
}
