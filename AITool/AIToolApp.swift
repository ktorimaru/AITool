//
//  AIToolApp.swift
//  AITool
//
//  Created by Ken Torimaru on 7/12/23.
//

import SwiftUI

@main
struct AIToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Model())
        }
    }
}
