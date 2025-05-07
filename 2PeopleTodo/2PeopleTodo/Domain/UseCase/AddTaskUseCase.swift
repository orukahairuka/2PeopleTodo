//
//  AddTaskUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// AddTaskUseCase.swift

import Foundation

/// タスク追加ユースケースのプロトコル
protocol AddTaskUseCaseProtocol {
    func execute(title: String, groupCode: String, createdBy: String, userId: String)
}

/// 実際のタスク追加処理
class AddTaskUseCase: AddTaskUseCaseProtocol {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(title: String, groupCode: String, createdBy: String, userId: String) {
        let newTask = TaskEntity(
            id: UUID().uuidString,
            title: title,
            isCompleted: false,
            completedAt: nil,
            createdBy: createdBy,
            userId: userId
        )
        repository.addTask(newTask, groupCode: groupCode)
    }
}
