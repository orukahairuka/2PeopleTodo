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
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationStack {
                CompletedTasksView(viewModel: viewModel.completedViewModel)
            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
    }
}
