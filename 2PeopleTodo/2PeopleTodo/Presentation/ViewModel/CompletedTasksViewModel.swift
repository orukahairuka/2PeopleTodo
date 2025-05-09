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

    private let useCase: CompletedTasksUseCaseProtocol

    init(useCase: CompletedTasksUseCaseProtocol = CompletedTasksUseCase()) {
        self.useCase = useCase
    }

    var allUsers: [String] {
        useCase.getAllUsers(from: tasks, completedTasks: completedTasks)
    }

    var sortedFilteredCompletedTasks: [TaskEntity] {
        useCase.getFilteredCompletedTasks(from: completedTasks, selectedUser: selectedUser)
    }
}
