//
//  MainView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct MainView: View {
    private let viewModel: TodoListViewModel

    init(groupCode: String, username: String, userId: String) {
        let repository = TaskRepository()
        self.viewModel = TodoListViewModel()
    }

    var body: some View {
        TabView {
            NavigationView {
                TodoListView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationView {
                CompletedTasksView(viewModel: viewModel)
            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
    }
}
