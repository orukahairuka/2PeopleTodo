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
    @FocusState var focus:Bool



    var body: some View {
            VStack(spacing: 20) {
                if appState.isExistingUser {
                    if let existingUsername = appState.username {
                        Text("ようこそ！\(existingUsername)")
                            .font(.headline)
                            .padding()
                    }
                } else {
                    Form{
                        TextField("あなたの名前", text: $username)
                            .focused(self.$focus)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .onChange(of: username) { newValue in
                                if !newValue.isEmpty {
                                    isCheckingUser = true
                                    appState.checkUserExists(username: newValue) { exists in
                                        isCheckingUser = false
                                        if exists {
                                            errorMessage = "この名前は既に使用されています。名前を書き換えてください"
                                        } else {
                                            errorMessage = ""
                                        }
                                    }
                                }
                            }
                    }
                    .onTapGesture {
                        self.focus = false
                    }
                }
                ZStack {
                    Form{
                        TextField("グループコード", text: $groupCode)
                            .focused(self.$focus)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                    }
                    .onTapGesture {
                        self.focus = false
                    }
                    Button("グループに参加または作成") {
                        let usernameToUse = appState.isExistingUser ? (appState.username ?? "") : username
                        appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse) { success, error in
                            if !success {
                                errorMessage = error ?? "エラーが発生しました"
                            }
                        }
                    }
                    .disabled(groupCode.isEmpty || (!appState.isExistingUser && username.isEmpty) || isCheckingUser)
                    .padding(.top,40)
                }
                .padding(.top, 30)
                


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
