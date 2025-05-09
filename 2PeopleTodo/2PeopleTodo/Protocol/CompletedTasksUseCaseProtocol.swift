//
//  CompletedTasksUseCaseProtocol.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation

protocol CompletedTasksUseCaseProtocol {
    func getFilteredCompletedTasks(
        from tasks: [TaskEntity],
        selectedUser: String?
    ) -> [TaskEntity]

    func getAllUsers(from tasks: [TaskEntity], completedTasks: [TaskEntity]) -> [String]
}

