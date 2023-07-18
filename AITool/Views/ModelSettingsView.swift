//
//  ModelSettingsView.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/16/23.
//

import SwiftUI

struct ModelSettingsView: View {
    @EnvironmentObject var model: Model
    @State var idx = 0
    let names = ["gpt-3.5-turbo","gpt-4"]
    var body: some View {
        HStack(alignment: .center) {
            Picker("Model", selection: $model.currentPromptFile.model) {
                Text("gpt-3.5-turbo").tag("gpt-3.5-turbo")
                Text("gpt-4").tag("gpt-4")
            }//.onChange(of: idx, perform: { model.currentPromptFile.model = names[idx] })
            Slider(value: $model.currentPromptFile.temperature, in: 0...1) {
                               Text("Temperature:")
                           } minimumValueLabel: {
                               Text("0")
                           } maximumValueLabel: {
                               Text("1")
                           } onEditingChanged: {
                               print("\($0)")
                           }
            Text(" \(model.currentPromptFile.temperature)")
        }
    }
}

struct ModelSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ModelSettingsView()
    }
}
