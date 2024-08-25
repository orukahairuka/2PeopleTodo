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

    init() {
        // TabViewの背景を白色に設定
        UITabBar.appearance().backgroundColor = .white
        
        // NavigationBarの背景を白色に設定
        UINavigationBar.appearance().backgroundColor = .white
        
        // NavigationBarのタイトルの色を黒に設定（オプション）
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }

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
        .background(Color.white) // TabViewの背景を白に設定
        .accentColor(.blue) // タブアイコンの選択色を設定（オプション）
    }
}

// PreviewProvider
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState())
    }
}
