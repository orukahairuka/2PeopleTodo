//
//  CompletedTasksUseCase.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation

final class CompletedTasksUseCase: CompletedTasksUseCaseProtocol {
    func getFilteredCompletedTasks(from tasks: [TaskEntity], selectedUser: String?) -> [TaskEntity] {
        let filtered = selectedUser != nil
            ? tasks.filter { $0.createdBy == selectedUser }
            : tasks
        return filtered.sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }

    func getAllUsers(from tasks: [TaskEntity], completedTasks: [TaskEntity]) -> [String] {
        let users = Set(tasks.map { $0.createdBy } + completedTasks.map { $0.createdBy })
        return Array(users).sorted()
    }
}
