//
//  AuthenticationView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import Foundation
import SwiftUI

struct AuthenticationView: View {
    @State private var isShowingLogin = true
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                if isShowingLogin {
                    LoginView()
                } else {
                    RegistrationView()
                }

                Button(isShowingLogin ? "新規登録へ" : "ログインへ") {
                    isShowingLogin.toggle()
                }
            }
            .navigationTitle(isShowingLogin ? "ログイン" : "新規登録")
        }
    }
}
