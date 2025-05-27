import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        TabView {
            NavigationStack {
                TodoListView(
                    viewModel: viewModel.todoViewModel,
                    groupCode: viewModel.groupCode,
                    createdBy: viewModel.username,
                    userId: viewModel.userId
                )
                .navigationTitle("タスク一覧")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Label("グループを変更", systemImage: "arrow.uturn.backward")
                        }
                    }
                }
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationStack {
                CompletedTasksView(viewModel: viewModel.completedViewModel)
                    .navigationTitle("完了済み")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewModel.logout()
                            }) {
                                Label("グループを変更", systemImage: "arrow.uturn.backward")
                            }
                        }
                    }
            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
    }
}

