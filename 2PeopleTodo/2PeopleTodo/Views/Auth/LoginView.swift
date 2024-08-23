//
//  LoginView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var chatGroupPassword = ""
    @State private var errorMessage = ""
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

            Button("ログイン") {
                appState.signIn(email: email, password: password, groupPassword: chatGroupPassword) { success, error in
                    if success {
                        // ログイン成功時の処理
                        print("ログイン成功")
                        // ここで必要に応じて画面遷移などの処理を行う
                    } else {
                        // ログイン失敗時の処理
                        errorMessage = error ?? "ログインに失敗しました"
                    }
                }
            }
        }
    }
}
