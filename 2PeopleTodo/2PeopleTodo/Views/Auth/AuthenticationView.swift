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
    @FocusState private var focusedField: Field?
    @State private var isProcessing = false
    @State private var showRetryAlert = false
    
    enum Field: Hashable {
        case username
        case groupCode
    }
    
    var isInputValid: Bool {
        if AuthManager.shared.getLocalUsername() != nil {
            return !groupCode.isEmpty
        } else {
            return !username.isEmpty && !groupCode.isEmpty
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    
                    if let existingUsername = AuthManager.shared.getLocalUsername() {
                        Text("ようこそ！\(existingUsername)")
                            .foregroundColor(Color.black)
                            .font(.title2)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("あなたの名前")
                                .font(.headline)
                                .foregroundColor(Color.customTextColor)
                            TextField("名前を入力", text: $username)
                                .focused($focusedField, equals: .username)
                                .foregroundColor(Color.customTextColor)
                                .background(Color.customTextFormColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(AuthManager.shared.getLocalUsername() != nil)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("グループコード")
                            .font(.headline)
                            .foregroundColor(Color.customTextColor)
                        TextField("コードを入力", text: $groupCode)
                            .focused($focusedField, equals: .groupCode)
                            .foregroundColor(Color.customTextColor)
                            .background(Color.customTextFormColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                    }
                    .padding(.horizontal)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            joinGroup()
                        }) {
                            Text("グループに参加")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isInputValid ? Color.customAccentColor : Color.gray)
                                .cornerRadius(8)
                        }
                        .disabled(!isInputValid || isProcessing)
                        
                        Button(action: {
                            createGroup()
                        }) {
                            Text("新規グループ作成")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isInputValid ? Color.customAccentColor : Color.gray)
                                .cornerRadius(8)
                        }
                        .disabled(!isInputValid || isProcessing)
                    }
                    .padding(.horizontal)
                    
                    if isProcessing {
                        ProgressView()
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.customImageColor.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            ensureAnonymousAuth()
        }
        .alert(isPresented: $showRetryAlert) {
            Alert(
                title: Text("エラー"),
                message: Text("操作に失敗しました。再試行しますか？"),
                primaryButton: .default(Text("再試行")) {
                    if groupCode.isEmpty {
                        ensureAnonymousAuth()
                    } else {
                        joinOrCreateGroup(isCreating: false)
                    }
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }
    
    private func joinGroup() {
        joinOrCreateGroup(isCreating: false)
    }
    
    private func createGroup() {
        joinOrCreateGroup(isCreating: true)
    }
    
    private func joinOrCreateGroup(isCreating: Bool) {
        guard isInputValid else {
            showInputError()
            return
        }
        
        isProcessing = true
        let usernameToUse = AuthManager.shared.getLocalUsername() ?? username
        appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse, isCreating: isCreating) { success, errorMessage in
            DispatchQueue.main.async {
                isProcessing = false
                if success {
                    // 成功時の処理は appState.joinOrCreateGroup 内で行われます
                } else {
                    self.errorMessage = errorMessage ?? "不明なエラーが発生しました"
                    self.showRetryAlert = true
                }
            }
        }
    }
    
    private func ensureAnonymousAuth() {
        isProcessing = true
        appState.ensureAnonymousAuth { success in
            DispatchQueue.main.async {
                isProcessing = false
                if !success {
                    self.errorMessage = "認証に失敗しました。再試行してください。"
                    self.showRetryAlert = true
                }
            }
        }
    }
    
    private func showInputError() {
        if AuthManager.shared.getLocalUsername() == nil && username.isEmpty {
            errorMessage = "ユーザー名を入力してください"
        } else if groupCode.isEmpty {
            errorMessage = "グループコードを入力してください"
        } else {
            errorMessage = "入力内容を確認してください"
        }
    }
}
