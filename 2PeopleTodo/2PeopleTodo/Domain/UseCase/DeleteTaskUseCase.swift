//
//  DeleteTaskUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// DeleteTaskUseCase.swift

import Foundation

/// タスク削除ユースケースのプロトコル
protocol DeleteTaskUseCaseProtocol {
    func execute(task: Task, groupCode: String)
}

/// Firestore経由でタスクを削除するユースケースの実装
class DeleteTaskUseCase: DeleteTaskUseCaseProtocol {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(task: Task, groupCode: String) {
        repository.deleteTask(task, groupCode: groupCode)
    }
}
