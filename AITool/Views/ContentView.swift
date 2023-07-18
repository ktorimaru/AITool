//
//  ContentView.swift
//  AITool
//
//  Created by Ken Torimaru on 7/12/23.
//

import SwiftUI
import FileView

struct ContentView: View {
    @EnvironmentObject var model: Model
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
#if os(macOS)
    @State var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView (columnVisibility: $visibility) {
            ScrollView {
                VStack {
                    FileItemView(fileItem: model.fvModel.home)
                        .environmentObject(model.fvModel)
                    Spacer()
                }
            }.padding([.leading])
        } detail: {
            if model.selected != nil {
                //Text("Selected: \(model.fvModel.selected?.name ?? "---")")
                ToolView()
                    .alert("Error trying to Iteration", isPresented: $model.showError, actions: {})
            } else {
                InstructionsView()
                
            }
        }
        .toolbar(){
            Button("New") {
                model.newFileIsPresented.toggle()
            }
            .popover(isPresented: $model.newFileIsPresented, content: NewPromptFile.init)
            
            if model.selected != nil {
                Button("Save") {
                    do {
                        try model.currentPromptFile.saveFile()
//                        model.lastSaved = Date()
                        print("file saved")
                        
                    } catch {
                        print("Couldn't save")
                    }
                }
                Button("**Iterate**") {
                    model.saveCurrentPromptFile()
                    model.runIterateChat()
                }
                .buttonStyle(ColorButtonStyle())
            }
            //        }
            Button(action : { model.showKeyView.toggle() }) {
                Image(systemName: "gear")
            }
            .popover(isPresented: $model.showKeyView, content: SetKeyView.init)
            Button(action : { model.showCoffee.toggle() }) {
                Text("☕️").font(.largeTitle)
            }.buttonStyle(.borderless)
            .popover(isPresented: $model.showCoffee, content: Coffee.init)

        }

    }
#else
    var body: some View {
        NavigationStack {
            Text("AITool")
                .hidden()
                .navigationTitle("AITool")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    Button("New") {
                        print("New")
                        model.newFileIsPresented.toggle()
                    }
                    .popover(isPresented: $model.newFileIsPresented, content: NewPromptFile.init)
                    .buttonStyle(ColorButtonStyle())
                     Button("Toggle") {
                         model.showDetail.toggle()
                     }
                }
            ScrollView {
                VStack {
                    FileItemView(fileItem: model.fvModel.home)
                        .environmentObject(model.fvModel)
                        .padding([.leading])
                    Spacer()
                    NavigationLink("Mint", value: Color.mint)
                        .navigationDestination(isPresented: $model.showDetail){
                            //Text("Selected: \(model.selected?.name ?? "---")")
                            ToolView()
                                .navigationTitle("Detail")
                        }
                        .hidden()
                }
            }
        }
    }
#endif
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
