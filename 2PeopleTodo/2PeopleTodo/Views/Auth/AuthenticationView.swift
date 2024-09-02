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
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case username
        case groupCode
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    if appState.isExistingUser {
                        if let existingUsername = appState.username {
                            Text("ようこそ！\(existingUsername)")
                                .font(.headline)
                                .padding()
                        }
                    } else {
                        CustomStyledForm {
                            TextField("あなたの名前", text: $username)
                                .focused($focusedField, equals: .username)
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
                        .frame(height: 100)
                        .padding(.horizontal)
                    }
                    
                    CustomStyledForm {
                        TextField("グループコード", text: $groupCode)
                            .focused($focusedField, equals: .groupCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .autocapitalization(.allCharacters)
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                    
                    Button(action: {
                        let usernameToUse = appState.isExistingUser ? (appState.username ?? "") : username
                        appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse) { success, error in
                            if !success {
                                errorMessage = error ?? "エラーが発生しました"
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.customAccentColor)
                                .frame(width: 220, height: 40)
                            
                            Text("グループに参加または作成")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .disabled(groupCode.isEmpty || (!appState.isExistingUser && username.isEmpty) || isCheckingUser)
                    .padding(.top, 40)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    // ... 既存のUI要素 ...
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.customImageColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            appState.ensureAnonymousAuth { success in
                if success {
                    if let savedUsername = UserDefaults.standard.string(forKey: "savedUsername") {
                        appState.checkUserExists(username: savedUsername) { exists in
                            if exists {
                                appState.username = savedUsername
                            }
                        }
                    }
                } else {
                    errorMessage = "認証に失敗しました。再試行してください。"
                }
            }
        }
    }
}
