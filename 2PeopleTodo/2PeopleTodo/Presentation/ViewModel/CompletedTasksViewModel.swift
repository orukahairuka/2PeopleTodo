//
//  CompletedTasksViewModel.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation
import Combine
import SwiftUI

final class CompletedTasksViewModel: ObservableObject {
    @Published var completedTasks: [TaskEntity] = []
    @Published var tasks: [TaskEntity] = []
    @Published var selectedUser: String?

    private var cancellables = Set<AnyCancellable>()
    private let useCase: CompletedTasksUseCaseProtocol

    init(from todoViewModel: TodoListViewModel,
         useCase: CompletedTasksUseCaseProtocol = CompletedTasksUseCase()) {
        self.useCase = useCase

        // 初期同期
        self.tasks = todoViewModel.tasks
        self.completedTasks = todoViewModel.completedTasks

        // リアルタイム同期
        todoViewModel.$tasks
            .sink { [weak self] in self?.tasks = $0 }
            .store(in: &cancellables)

        todoViewModel.$completedTasks
            .sink { [weak self] in self?.completedTasks = $0 }
            .store(in: &cancellables)
    }

    var allUsers: [String] {
        useCase.getAllUsers(from: tasks, completedTasks: completedTasks)
    }

    var sortedFilteredCompletedTasks: [TaskEntity] {
        useCase.getFilteredCompletedTasks(from: completedTasks, selectedUser: selectedUser)
    }
}
