//
//  Model.swift
//  FileViewExample
//
//  Created by Ken Torimaru on 6/23/23.
//

import Foundation
import FileView
import SwiftUI
import Combine
import OpenAISwift

class Model: ObservableObject {
    
    init() {
        cancellable = fvModel.$selected.assign(to: \.selected, on: self)
        let _ = FileManager.default.changeCurrentDirectoryPath(URL.documentsDirectory.path())
        print(FileManager.default.currentDirectoryPath)
        showKeyView = (defaults.string(forKey: "openai") == nil || defaults.string(forKey: "openai") == nil)
        if let key = defaults.string(forKey: "openai") {
            if !showKeyView {
                openAIKey = key
                gotKey = true
            }
        }
    }
    var openAI: OpenAISwift?
    
    @ObservedObject var fvModel = FileViewModel(
        home:
            FileItem(
                path: URL.documentsDirectory,
                name: "Documents",
                load: true,
                expanded: true,
                isDir: true,
                ext: "json")
    )
    
    var home: FileItem {
        fvModel.home
    }
    @Published var currentPromptFile: PromptFile = PromptFile()
    
    @Published var selected: FileItem? {
        willSet {
            if let value = newValue, let path = value.path {
                if !value.isDirectory {
                    do {
                        print(path)
                        lastChatRun = [ChatMessage]()
                        currentPromptFile = try PromptFile(from: path)
                        showDetail.toggle()
                    } catch {
                        print("\(#function) Model Error \n\(path.absoluteString)\n\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    var cancellable: AnyCancellable?
    @Published var newFileIsPresented = false
    @Published var showDetail = false
    @Published var lastChatRun: [ChatMessage] = [ChatMessage]()
    let defaults = UserDefaults.standard
    var gotKey: Bool = false
    @Published var openAIKey = "" {
        willSet {
            let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey:newValue)
            openAI = OpenAISwift(config: config)
            gotKey = true
        }
    }
    @Published var showKeyView = false
    @Published var showError = false
    @Published var showWorking = false
    
    @Published var lastError: Error?
    @Published var showCoffee = false
    var task: Task<Void, Never>?
    var task2: Task<[ChatMessage], Error>?
    
    func runIterateChat() {
        task = Task {
            do {
                let chat = try await iterateChat()
//                try Task.checkCancellation()
                if Task.isCancelled {
                    return
                }
                DispatchQueue.main.async {
                    self.lastChatRun = chat
                    if self.lastChatRun.count > self.currentPromptFile.tableMessages.count {
                        for idx in self.currentPromptFile.tableMessages.count..<self.lastChatRun.count {
                            self.currentPromptFile.tableMessages.append(TableMessage(role: self.lastChatRun[idx].role!.tableRole(), content: self.lastChatRun[idx].content ?? "ERR"))
                        }
                    }
                }
            } catch {
                if type(of: error) != CancellationError.self {
                    print("\(#function) Error: \(error.localizedDescription)")
                    lastError = error
                    showError.toggle()
                }
            }
        }

    }

    func iterateChat() async throws -> [ChatMessage] {
        var temp = [ChatMessage]()
        let chat = Task { () -> [ChatMessage] in
            var chatMessages: [ChatMessage]  = [ChatMessage]()
            var index = 0
            var skip = false
            do {
                for message in self.currentPromptFile.tableMessages {
                    if message.role != .testor && !skip {
                        let current = ChatMessage(role: message.role.chatRole(), content: message.content)
                        chatMessages.append(current)
                        print("\(index): \(current.content ?? "ERR")")
                    } else if message.role == .testor {
                        let current = ChatMessage(role: message.role.chatRole(), content: message.content)
                        chatMessages.append(current)
                        print("\(index): \(current.content ?? "ERR")")
                        chatMessages = try await sendChat(with: chatMessages)
                        if chatMessages.count < self.currentPromptFile.tableMessages.count &&
                            chatMessages.last?.content == self.currentPromptFile.tableMessages[index + 1].content
                        {
                            print("Match")
                        } else {
                            print("NEW")
                            print(chatMessages.last?.content ?? "")
                            print("OLD")
                            if index + 1 < self.currentPromptFile.tableMessages.count {
                                print(self.currentPromptFile.tableMessages[index + 1].content)
                            }
                        }
                        skip = true
                        index += 1
                    } else {
                        skip = false
                        index -= 1
                    }
                    index += 1
                }
            } catch {
                throw error
            }
            return chatMessages
        }
        let result = await chat.result
        
        do {
            let chatArray = try result.get()
            print("Got chatArray \(chatArray.count)")
            temp = chatArray
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
        showWorking = false
        return temp
    }

    func sendChat(with: [ChatMessage]) async throws -> [ChatMessage] {
        var temp = with
        if let ai = openAI {
            
            do {
                
                let result = try await ai.sendChat(
                    with: temp,
                    model: (currentPromptFile.model == "gpt-3.5-turbo" ?  OpenAIModelType.chat(.chatgpt) : .gpt4(.gpt4)),
                    temperature: currentPromptFile.temperature)
                //let result = try await ai.sendChat(with: temp, model: .gpt4(.gpt4) , temperature: currentPromptFile.temperature)
//                try Task.checkCancellation()
                if let choice = result.choices?.first, let _ = result.choices?.count {
                    temp.append(choice.message)
                }
            } catch {
                // ...
                print("\(#function) Error: \(error.localizedDescription)")
                throw error
            }
        }
        return temp
    }

    func saveCurrentPromptFile() {
        do {
            currentPromptFile.modified = Date()
            try currentPromptFile.saveFile()
            print("\(#function) Saved")
        } catch {
            print("\(#function) \(error.localizedDescription)")
        }
    }

    func removePrompt(index: Int) {
        if index >= 0 && index < currentPromptFile.tableMessages.count {
            DispatchQueue.main.async {
                self.currentPromptFile.tableMessages.remove(at: index)
            }
        }
    }

    func copyAddPrompt(index: Int) {
        if index >= 0 && index < currentPromptFile.tableMessages.count {
            var temp = currentPromptFile.tableMessages[index]
            temp.id = UUID()
            DispatchQueue.main.async {
                self.currentPromptFile.tableMessages.insert(temp, at: index)
            }
        }
    }

    func replaceOldAssistant(index: Int) {
        currentPromptFile.tableMessages[index].content = (lastChatRun[index].content ?? "")
        saveCurrentPromptFile()
    }
    
    func simplePromptFile(fileName: String) -> PromptFile {
        var temp = PromptFile()
        temp.name = fileName
        temp.model = "gpt-3.5-turbo"
        temp.fileName = "\(fileName).json"
        temp.tableMessages = [TableMessage]()
        temp.tableMessages.append(
            TableMessage(role: .system, content: "You are a helpful assistant.")
        )
        do {
            try temp.saveFile()
        } catch {
            print("\(#function) Error: \(error.localizedDescription)")
        }
        return temp
    }
    
    func blankPromptFile(fileName: String) -> PromptFile {
        var temp = PromptFile()
        temp.name = fileName
        temp.model = "gpt-3.5-turbo"
        temp.fileName = "\(fileName).json"
        temp.tableMessages = [TableMessage]()
        do {
            try temp.saveFile()
        } catch {
            print("\(#function) Error: \(error.localizedDescription)")
        }
        return temp
    }
    
    func pizzaPromptFile(fileName: String) -> PromptFile {
        var temp = PromptFile()
        temp.name = fileName
        temp.model = "gpt-3.5-turbo"
        temp.fileName = "\(fileName).json"
        temp.tableMessages = [TableMessage]()
        temp.tableMessages.append(
            TableMessage(role: .system, content: "You are a helpful assistant.")
        )
        temp.tableMessages.append(
            TableMessage(role: .system, content:
                                    "You are TONI, an automated service, that speaks like Joe Pesci, to collect orders for a pizza restaurant. You first insult the customer, then collects the order, and then asks if it's a pickup or delivery. If the question does not relate to ordering food refer the customer to 'Pinky' or 'The Brain'. You wait to collect the entire order, then summarize it and check for a final time if the customer wants to add anything else. If it's a delivery, you ask for an address. Finally you collect the payment. Make sure to clarify all options, extras and sizes to uniquely identify the item from the menu. Your responses should be slightly confrontational. Remember if the name of the pizza includes an 'and' or 'with' they are adding a topping The menu includes pepperoni pizza  12.95, 10.00, 7.00 cheese pizza   10.95, 9.25, 6.50 eggplant pizza   11.95, 9.75, 6.75 fries 4.50, 3.50 greek salad 7.25 Toppings: extra cheese 2.00, mushrooms 1.50 sausage 3.00 canadian bacon 3.50 AI sauce 1.50 peppers 1.00 Drinks: coke 3.00, 2.00, 1.00 sprite 3.00, 2.00, 1.00 bottled water 5.00 "
                                             )
        )
        temp.tableMessages.append(
            TableMessage(role: .testor, content: "I'd like a pizza")
        )
        do {
            try temp.saveFile()
        } catch {
            print("\(#function) Error: \(error.localizedDescription)")
        }
        return temp
    }
    
    func refreshDir(){
//        fvModel.$selected = selected
        DispatchQueue.main.async {
            self.fvModel.objectWillChange.send()
        }
    }

}
