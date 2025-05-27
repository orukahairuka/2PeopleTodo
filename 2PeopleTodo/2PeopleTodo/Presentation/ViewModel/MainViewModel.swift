//
//  MainViewModel.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/19.
//
import SwiftUI

final class MainViewModel: ObservableObject {
    let groupCode: String
    let username: String
    let userId: String

    let todoViewModel: TodoListViewModel
    let completedViewModel: CompletedTasksViewModel

    // ✅ AppViewModelに通知するためのクロージャ
    var onLogout: (() -> Void)? = nil

    init(groupCode: String, username: String, userId: String) {
        self.groupCode = groupCode
        self.username = username
        self.userId = userId

        let repository = TaskRepository()
        let fetchTasksUseCase = FetchTasksUseCase(repository: repository)
        let addTaskUseCase = AddTaskUseCase(repository: repository)
        let deleteTaskUseCase = DeleteTaskUseCase(repository: repository)
        let completeTaskUseCase = CompleteTaskUseCase(repository: repository)

        self.todoViewModel = TodoListViewModel(
            taskRepository: repository,
            fetchTasksUseCase: fetchTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            completeTaskUseCase: completeTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )

        self.completedViewModel = CompletedTasksViewModel(from: todoViewModel)
    }

    // ✅ ログアウトアクション
    func logout() {
        onLogout?()
    }
}
