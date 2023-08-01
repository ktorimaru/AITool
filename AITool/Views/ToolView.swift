//
//  ToolView.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/1/23.
//

import SwiftUI
import FileView
struct ToolView: View {
    @EnvironmentObject var model: Model
    @State var isGray = false
    let oddColor = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.07)
    
    var body: some View {
        VStack {
            Group {
                HStack(alignment: .top) {
                    TextField("Name", text: $model.currentPromptFile.name ).font(.headline)
                    Spacer()
                    Text("Created: \(model.currentPromptFile.timestamp, formatter: dateFormatter)")
                }
                .padding([.top])
                HStack(alignment: .top) {
                    TextField("File Name", text: $model.currentPromptFile.fileName ).font(.body)
                    Spacer()
                    Text("Modified: \(model.currentPromptFile.modified, formatter: dateFormatter)")
                }
                ModelSettingsView()
            }.padding([.leading, .trailing])
            Divider()
            HStack {
                Text("Prompt Script")
#if (macOS)
                .font(.largeTitle)
#else
                .font(.headline)
#endif
                Spacer()
            }.padding([.leading, .trailing])
            ScrollView(.vertical) {
                ForEach(0..<model.currentPromptFile.tableMessages.count, id: \.self) { idx in
                    HStack(alignment: .top, spacing: 0){
                        Group {
                            if model.currentPromptFile.tableMessages[idx].role == .assistant {
                                if model.lastChatRun.count > 0 && model.currentPromptFile.tableMessages[idx].content != model.lastChatRun[idx].content {
                                    VStack {
                                        HStack {
                                            Text("**Old**").padding([.leading, .trailing])
                                            Spacer()
                                        }.frame(maxWidth: .infinity)
                                        AssistantView(text: model.currentPromptFile.tableMessages[idx].content ).frame(maxWidth: .infinity)
                                        Divider()
                                        HStack {
                                            Text("**New**").padding([.leading, .trailing])
                                            Spacer()
                                        }.frame(maxWidth: .infinity)
                                        AssistantView(text: model.lastChatRun[idx].content ?? "").frame(maxWidth: .infinity)
                                        Button("Replace Old") {
                                            print("Replace Old")
                                           model.replaceOldAssistant(index: idx)
                                        
                                        }
                                        .buttonStyle(ColorButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding([.bottom], 4)
                                    }
                                } else {
                                    AssistantView(text: model.currentPromptFile.tableMessages[idx].content).frame(maxWidth: .infinity)
                                }
                            } else {
                                if model.lastChatRun.count > 0 {
                                    TableRowPicker(index: idx)
                                        .font(.body)
                                        .padding(4)
                                        .frame(width: 100, alignment: .leading)
                                    TextEditor(text: $model.currentPromptFile.tableMessages[idx].content)
                                        .font(.body)
                                        .padding(4)
                                } else {
                                    TableRowPicker(index: idx)
                                        .font(.body)
                                        .padding(4)
                                        .frame(width: 100, alignment: .leading)
                                    TextEditor(text: $model.currentPromptFile.tableMessages[idx].content)
                                        .font(.body)
                                        .padding(4)
                                }
                            }
                            //Spacer()
                            //if model.currentPromptFile.tableMessages[idx].role != .assistant {
                            VStack(alignment: .trailing) {
                                    Toggle(isOn: $model.currentPromptFile.tableMessages[idx].save, label: {EmptyView()})
#if (macOS)
                                    .toggleStyle(.automatic)
#else
                                    .toggleStyle(CheckboxStyle())
#endif
                                        
//                                        .frame(width: 24)
                                    Button(action: {
                                        DispatchQueue.main.async {
                                            model.removePrompt(index: idx)
                                            print("model.removePrompt(index: idx)")
                                        }
                                    }) {
                                        Image(systemName: "minus.circle")
//                                            .font(.title)
                                    }.buttonStyle(BorderlessButtonStyle())
                                    Button(action: {
                                        DispatchQueue.main.async {
                                            model.copyAddPrompt(index: idx)
                                            print("model.copyAddPrompt(index: idx)")
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
//                                            .font(.title)
                                    }.buttonStyle(BorderlessButtonStyle())
                                }
                                .frame(maxWidth: 20)
                                .padding()
                        }
                        .padding(idx % 2 == 0 ? [.top, .bottom] : [], idx % 2 == 0 ? 8 : 0)


                    }
                    .background( idx % 2 == 0 ? oddColor : Color.white)
                    if idx % 2 != 0  && idx + 1 == model.currentPromptFile.tableMessages.count {
                        Rectangle()
                            .fill(oddColor)
                            .frame(maxWidth:.infinity)
                    }
                    
                }
                Button(action: {
                    model.currentPromptFile.tableMessages.append(TableMessage(role: .testor, content: ""))
                    
                }) {
                    Image(systemName: "plus.circle").font(.title)
                }.buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing])

            }
            .navigationTitle(model.currentPromptFile.name)
            .toolbarTitleMenu(){
                RenameButton()
            }
            Spacer()
        }//.padding()
    }
}

struct ToolView_Previews: PreviewProvider {
    static var previews: some View {
        ToolView()
    }
}
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

