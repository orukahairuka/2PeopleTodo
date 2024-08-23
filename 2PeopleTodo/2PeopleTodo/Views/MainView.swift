//
//  MainView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var todoListViewModel = TodoListViewModel()

    var body: some View {
        TabView {
            NavigationView {
                TodoListView()
                    .environmentObject(appState)
                    .environmentObject(todoListViewModel)
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationView {
                CompletedTasksView(viewModel: todoListViewModel)
                    .environmentObject(appState)
            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
        .onAppear {
            if let groupCode = appState.groupCode {
                todoListViewModel.fetchTasks(groupCode: groupCode)
            }
        }
    }
}



