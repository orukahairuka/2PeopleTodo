//
//  RegisterdView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = "test@email.com"
    @State private var password = "@test12345"
    @State private var chatGroupPassword = "@test12345"
    @State private var errorMessage = "ダメ"
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            TextField("メールアドレス", text: $email)
            SecureField("パスワード", text: $password)
            SecureField("チャットグループパスワード", text: $chatGroupPassword)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("登録") {
                appState.signUp(email: email, password: password, groupPassword: chatGroupPassword) { success, error in
                    if success {
                        // 登録成功時の処理
                        print("登録成功")
                    } else {
                        // 登録失敗時の処理
                        errorMessage = error ?? "新規登録に失敗しました"
                    }
                }
            }
        }
    }
}
