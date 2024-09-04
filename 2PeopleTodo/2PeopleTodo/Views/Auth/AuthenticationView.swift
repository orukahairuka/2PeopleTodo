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
                            .font(.title2)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("あなたの名前")
                                .font(.headline)
                            TextField("名前を入力", text: $username)
                                .focused($focusedField, equals: .username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(AuthManager.shared.getLocalUsername() != nil)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("グループコード")
                            .font(.headline)
                        TextField("コードを入力", text: $groupCode)
                            .focused($focusedField, equals: .groupCode)
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
    }
    
    private func joinGroup() {
        guard isInputValid else {
            showInputError()
            return
        }
        
        isProcessing = true
        let usernameToUse = AuthManager.shared.getLocalUsername() ?? username
        appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse, isCreating: false) { success, errorMessage in
            DispatchQueue.main.async {
                isProcessing = false
                if success {
                    // 成功時の処理は appState.joinOrCreateGroup 内で行われます
                } else {
                    self.errorMessage = errorMessage ?? "不明なエラーが発生しました"
                }
            }
        }
    }
    
    private func createGroup() {
        guard isInputValid else {
            showInputError()
            return
        }
        
        isProcessing = true
        let usernameToUse = AuthManager.shared.getLocalUsername() ?? username
        appState.joinOrCreateGroup(groupCode: groupCode, username: usernameToUse, isCreating: true) { success, errorMessage in
            DispatchQueue.main.async {
                isProcessing = false
                if success {
                    // 成功時の処理は appState.joinOrCreateGroup 内で行われます
                } else {
                    self.errorMessage = errorMessage ?? "不明なエラーが発生しました"
                }
            }
        }
    }
    
    private func showInputError() {
        if username.isEmpty && AuthManager.shared.getLocalUsername() == nil {
            errorMessage = "ユーザー名を入力してください"
        } else if groupCode.isEmpty {
            errorMessage = "グループコードを入力してください"
        }
    }
    
    private func ensureAnonymousAuth() {
        AuthManager.shared.signInAnonymously { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 認証成功時の処理は特に必要ありません。
                    break
                case .failure(let error):
                    self.errorMessage = "認証に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}
