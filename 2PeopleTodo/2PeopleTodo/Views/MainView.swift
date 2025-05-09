//
//  MainView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct MainView: View {
    private let todoViewModel: TodoListViewModel
    private let completedViewModel: CompletedTasksViewModel

    init(groupCode: String, username: String, userId: String) {
        let repository = TaskRepository()
        self.todoViewModel = TodoListViewModel()
        self.completedViewModel = CompletedTasksViewModel()
    }

    var body: some View {
        TabView {
            NavigationView {
                TodoListView()
                    .environmentObject(todoViewModel)
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationView {
                CompletedTasksView(viewModel: completedViewModel) // ← 正しく CompletedTasksViewModel を渡している

            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
    }
}

struct TodoListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel

    var body: some View {
        VStack {
            Text("タスク一覧")
            // 本来はここに List や Form などが入ります
        }
        .navigationTitle("タスク")
    }
}

