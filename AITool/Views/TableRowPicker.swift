//
//  TableRowPicker.swift
//  PromptEditor
//
//  Created by Ken Torimaru on 6/8/23.
//

import SwiftUI

struct TableRowPicker: View {
    @EnvironmentObject var model: Model
    var index: Int
    var body: some View {
        if index < model.currentPromptFile.tableMessages.count {
            Picker("", selection: $model.currentPromptFile.tableMessages[index].role) {
                ForEach(TableRole.allCases) { val in
                    Text(String(describing:val))
                }
            }
        }
    }
}

struct TableRowPicker_Previews: PreviewProvider {
    static var previews: some View {
        TableRowPicker(index: 0)
    }
}
