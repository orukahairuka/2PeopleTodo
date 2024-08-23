//
//  AuthenticationView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var groupCode = ""
    @State private var username = ""
    @State private var errorMessage = ""
    @State private var isCheckingUser = false

    var body: some View {
        VStack(spacing: 20) {
            Text("2人用ToDoリスト")
                .font(.largeTitle)

            if appState.isExistingUser {
                if let existingUsername = appState.username {
                    Text("ようこそ戻ってきました、\(existingUsername)さん")
                        .font(.headline)
                        .padding()
                }
            } else {
                TextField("あなたの名前", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: username) { newValue in
                        if !newValue.isEmpty {
                            isCheckingUser = true
                            appState.checkUserExists(username: newValue) { exists in
                                isCheckingUser = false
                                if exists {
                                    errorMessage = "この名前は既に使用されています。そのまま続けてください。"
                                } else {
                                    errorMessage = ""
                                }
                            }
                        }
                    }
            }

            TextField("グループコード", text: $groupCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .padding()

            Button("グループに参加または作成") {
                let usernameToUse = appState.isExistingUser ? (appState.username ?? "") : username
                appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse) { success, error in
                    if !success {
                        errorMessage = error ?? "エラーが発生しました"
                    }
                }
            }
            .disabled(groupCode.isEmpty || (!appState.isExistingUser && username.isEmpty) || isCheckingUser)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            if let savedUsername = UserDefaults.standard.string(forKey: "savedUsername") {
                appState.checkUserExists(username: savedUsername) { exists in
                    if exists {
                        appState.username = savedUsername
                    }
                }
            }
        }
    }
}
