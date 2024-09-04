//
//  AuthModeSelector.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/09/04.
//

import SwiftUI

struct AuthModeSelector: View {
    @Binding var selectedMode: AuthMode
    
    var body: some View {
        HStack(spacing: 20) {
            modeButton(.join)
            modeButton(.create)
        }
        .padding(.vertical, 10)
    }
    
    private func modeButton(_ mode: AuthMode) -> some View {
        Button(action: {
            selectedMode = mode
        }) {
            Text(mode == .join ? "グループに参加" : "新規グループ作成")
                .foregroundColor(selectedMode == mode ? .white : .primary)
                .padding()
                .background(selectedMode == mode ? Color.customAccentColor : Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

enum AuthMode {
    case join
    case create
}
