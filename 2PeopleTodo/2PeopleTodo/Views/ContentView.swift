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
                if appState.isAuthenticated, let groupCode = appState.groupCode, let username = appState.username {
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
    }

    private var logoutButton: some View {
        Button("ログアウト") {
            appState.signOut()
        }
    }
}
