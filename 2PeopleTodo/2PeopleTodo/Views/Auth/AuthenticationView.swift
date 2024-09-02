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
    
    enum Field: Hashable {
        case username
        case groupCode
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    if let existingUsername = AuthManager.shared.getLocalUsername() {
                        Text("ようこそ！\(existingUsername)")
                            .font(.headline)
                            .padding()
                    } else {
                        CustomStyledForm {
                            TextField("あなたの名前", text: $username)
                                .focused($focusedField, equals: .username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .disabled(AuthManager.shared.getLocalUsername() != nil)
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
                        let usernameToUse = AuthManager.shared.getLocalUsername() ?? username
                        joinOrCreateGroup(groupCode: groupCode, username: usernameToUse)
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
                    .disabled(groupCode.isEmpty || (AuthManager.shared.getLocalUsername() == nil && username.isEmpty))
                    .padding(.top, 40)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.customImageColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            ensureAnonymousAuth()
        }
    }
    
    private func joinOrCreateGroup(groupCode: String, username: String) {
        AuthManager.shared.joinOrCreateGroupWithLocalUsernameCheck(groupCode: groupCode, username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groupCode):
                    self.appState.groupCode = groupCode
                    self.appState.username = username
                    // ここで必要な画面遷移やステート更新を行う
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func ensureAnonymousAuth() {
        AuthManager.shared.signInAnonymously { result in
            DispatchQueue.main.async {
                switch result {
                case .success: break
                    // 認証成功時の処理（必要に応じて）
                case .failure(let error):
                    self.errorMessage = "認証に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}
