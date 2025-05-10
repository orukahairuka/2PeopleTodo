//
//  AuthenticationView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    @State private var showRetryAlert = false

    enum Field: Hashable {
        case username
        case groupCode
    }

    var isInputValid: Bool {
        !viewModel.username.isEmpty && !viewModel.groupCode.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("あなたの名前", text: $viewModel.username)
                    .focused($focusedField, equals: .username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("グループコード", text: $viewModel.groupCode)
                    .focused($focusedField, equals: .groupCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    Button("グループに参加") {
                        viewModel.joinOrCreateGroup(isCreating: false)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isInputValid)

                    Button("新規グループ作成") {
                        viewModel.joinOrCreateGroup(isCreating: true)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isInputValid)
                }

                

                if viewModel.errorMessage != nil {
                    Button("再試行") {
                        viewModel.signInAnonymously()
                    }
                    .padding(.top)
                }

                Spacer()

                // 画面遷移リンク（非表示）
                NavigationLink(
                    destination: MainView(
                        groupCode: viewModel.groupCode,
                        username: viewModel.username,
                        userId: viewModel.userId
                    ),
                    isActive: $viewModel.shouldNavigate
                ) {
                    EmptyView()
                }
            }
            .padding()
            .onAppear {
                viewModel.signInAnonymously()
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
}
