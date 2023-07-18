//
//  DataStructs.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/1/23.
//

import Foundation
import OpenAISwift

public enum ModelNames: String, CaseIterable, Identifiable {
    case gpt35 = "gpt-3.5-turbo"
    case gpt4 = "gpt-4"
    public var id: Self { self }
}

/// An enumeration of possible roles in a chat conversation.
public enum TableRole: String, Codable, CaseIterable, Identifiable {
    /// The role for the system that manages the chat interface.
    case system
    /// The role for the human user who initiates the chat.
    case user
    /// The role for the artificial assistant who responds to the user.
    case assistant
    /// The role to simulate the human user.
    case testor
    
    public var id: Self { self }
    func chatRole() -> ChatRole {
        switch self {
        case .system:
            return .system
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .testor:
            return .user
        }
        
    }
}

struct TableMessage: Identifiable, Codable {
    var id = UUID()
    var timestamp = Date()
    /// The sequence of execution
    var order = 0
    /// The role of the sender of the message.
    var role: TableRole
    /// The content of the message.
    var content: String
    /// Save this content in file
    var save: Bool = true
}
struct FileMeta: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
}
struct PromptFile: Identifiable, Codable {
    
    var id = UUID()
    var timestamp = Date()
    var modified = Date()
    var name: String = ""
    var fileName = ""
    var model: String = ""
    var temperature: Double = 0.0
    
    var tableMessages = [TableMessage]()
    
    func saveFile() throws {
        var copy = self
        copy.modified = Date()
        copy.tableMessages = copy.tableMessages.filter({$0.save})
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(copy)
        let fileManager = FileManager.default
        let currentDirectoryURL = fileManager.currentDirectoryPath
        let fileURL = URL(fileURLWithPath: currentDirectoryURL).appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.modified = try container.decode(Date.self, forKey: .modified)
        self.name = try container.decode(String.self, forKey: .name)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.model = try container.decode(String.self, forKey: .model)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.tableMessages = try container.decode([TableMessage].self, forKey: .tableMessages)
    }
    
    init(from fileurl: URL) throws {
        guard let data = try? Data(contentsOf: fileurl) else {
            print("\(#function) PromptFile Error \(fileurl.absoluteString)")
            return
        }
        self = try JSONDecoder().decode(PromptFile.self, from: data)
        print("\(#function): \(self.fileName)")
    }
    
    init(){
        self.id = UUID()
        self.timestamp = Date()
        self.modified = Date()
        self.name = ""
        self.fileName = ""
        self.model = ""
        self.temperature = 0
        self.tableMessages = [TableMessage]()
    }
}

extension PromptFile: Hashable {
    static func == (lhs: PromptFile, rhs: PromptFile) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChatRole {
    func tableRole() -> TableRole {
        switch self {
        case .system:
            return .system
        case .user:
            return .user
        case .assistant:
            return .assistant
        }

    }
}

