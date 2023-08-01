//
//  ContentView.swift
//  AITool
//
//  Created by Ken Torimaru on 7/12/23.
//

import SwiftUI
import FileView
#if os(iOS)
import UIKit
#endif
struct ContentView: View {
    @EnvironmentObject var model: Model
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    @State var visibility: NavigationSplitViewVisibility = .automatic
    @State var update = false
    var body: some View {
        NavigationSplitView (columnVisibility: $visibility) {
#if os(iOS)
            if UIDevice.current.model == "iPhone" {
                FileView()
                    .environmentObject(model.fvModel)
                    .toolbar(){
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                withAnimation {
                                    model.showDetail.toggle()
                                }
                            }) {
                                Image(systemName: "sidebar.leading")
                            }
                            Spacer()
                        }
                    }
                    .navigationTitle("Directory")
                    .navigationBarTitleDisplayMode(.inline)
                NavigationLink("Detail", value: Color.clear)
                    .navigationDestination(isPresented: $model.showDetail){
                        TabView {
                            if model.selected != nil && !model.selected!.isDirectory {
                                ToolView()
                                    .tabItem({ Text("Chat") })
                            } else {
                                InstructionsView()
                                    .tabItem({ Text("Chat") })
                            }
                            Text("Image")
                                .tabItem({ Text("Image")})
                        }
                            .toolbar(){
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("New") {
                                        model.newFileIsPresented.toggle()
                                    }
                                }
                            }
                            .navigationTitle("AITool")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .hidden()
            } else {
                FileView()
                    .environmentObject(model.fvModel)
            }
#else
            FileView()
                .environmentObject(model.fvModel)
#endif
        } detail: {
            TabView {
                if model.selected != nil && !model.selected!.isDirectory {
                    ToolView()
                        .alert("Error trying to Iteration", isPresented: $model.showError, actions: {})
                        .tabItem({ Text("Chat") })
                    
                } else {
                    InstructionsView()
                        .tabItem({ Text("Chat") })
                    
                }
                Text("Image")
                    .tabItem({ Text("Image")})
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
                        model.showWorking = true
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
            .toolbarRole(.automatic)
            .navigationTitle("AITool")
#if os(iOS)
//            .toolbarBackground(.green .gradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            
#endif

            
        } //End detail
        .alert("Iterating", isPresented: $model.showWorking){
            Button("Cancel Iteration") {
                print("Cancel Iteration")
                model.task?.cancel()
            }
        }
        .onAppear() {
#if os(iOS)
            if UIDevice.current.model == "iPhone" {
                model.showDetail = true
            }
#endif
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
