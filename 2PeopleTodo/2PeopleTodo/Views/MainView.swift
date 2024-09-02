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
        // NavigationBarの背景を透明に設定
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        
        // TabBarの背景を白に設定
        UITabBar.appearance().backgroundColor = .white
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // 全体の背景を白に
            
            TabView {
                NavigationView {
                    ZStack {
                        Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all) // カスタムカラーの代わりに使用
                        
                        TodoListView()
                            .environmentObject(appState)
                            .environmentObject(todoListViewModel)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("タスク", systemImage: "list.bullet")
                }

                NavigationView {
                    ZStack {
                        Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all) // カスタムカラーの代わりに使用
                        
                        CompletedTasksView(viewModel: todoListViewModel)
                            .environmentObject(appState)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("完了済み", systemImage: "checkmark.circle")
                }
            }
            .onAppear {
                appState.ensureAnonymousAuth { success in
                    if success, let groupCode = appState.groupCode {
                        todoListViewModel.fetchTasks(groupCode: groupCode)
                    }
                }
            }
            .accentColor(.blue)
        }
    }
}
