//
//  MainView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

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
    private let groupCode: String
    private let username: String
    private let userId: String

    init(groupCode: String, username: String, userId: String) {
        self.groupCode = groupCode
        self.username = username
        self.userId = userId

        // Data層（Repository）
        let repository = TaskRepository()

        // Domain層（UseCase）
        let fetchTasksUseCase = FetchTasksUseCase(repository: repository)
        let addTaskUseCase = AddTaskUseCase(repository: repository)
        let deleteTaskUseCase = DeleteTaskUseCase(repository: repository)
        let completeTaskUseCase = CompleteTaskUseCase(repository: repository)

        // Presentation層（ViewModel）
        let todoVM = TodoListViewModel(
            taskRepository: repository,
            fetchTasksUseCase: fetchTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            completeTaskUseCase: completeTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
        self.todoViewModel = todoVM
        self.completedViewModel = CompletedTasksViewModel(from: todoVM)
    }

    var body: some View {
        TabView {
            NavigationView {
                TodoListView(
                    viewModel: todoViewModel,
                    groupCode: groupCode,
                    createdBy: username,
                    userId: userId
                )
            }
            .tabItem {
                Label("タスク", systemImage: "list.bullet")
            }

            NavigationView {
                CompletedTasksView(viewModel: completedViewModel)
            }
            .tabItem {
                Label("完了済み", systemImage: "checkmark.circle")
            }
        }
    }
}
