//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var todoListViewModel = TodoListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if appState.isAuthenticated {
                    authenticatedView
                } else {
                    loadingView
                }
            }
        }
        .background(Color.customImageColor.edgesIgnoringSafeArea(.all))
    }

    private var authenticatedView: some View {
        Group {
            if let groupCode = appState.groupCode, let username = appState.username {
                TabView {
                    TodoListView()
                        .environmentObject(appState)
                        .environmentObject(todoListViewModel)
                        .tabItem {
                            Label("タスク", systemImage: "list.bullet")
                        }

                    CompletedTasksView(viewModel: todoListViewModel)
                        .environmentObject(appState)
                        .tabItem {
                            Label("完了済み", systemImage: "checkmark.circle")
                        }
                }
                .navigationBarItems(leading: Text("ユーザー: \(username)"), trailing: logoutButton)
                .onAppear {
                    todoListViewModel.fetchTasks(groupCode: groupCode)
                }
            } else {
                AuthenticationView()
                    .environmentObject(appState)
            }
        }
    }

    private var loadingView: some View {
        ProgressView("準備中...")
            .onAppear {
                appState.checkAuthenticationStatus { success in
                    if !success {
                        print("認証状態の確認に失敗しました")
                    }
                }
            }
    }

    private var logoutButton: some View {
        Button("ログアウト") {
            appState.signOut()
        }
    }
}
