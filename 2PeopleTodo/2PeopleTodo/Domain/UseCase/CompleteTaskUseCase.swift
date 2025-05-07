//
//  CompleteTaskUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// CompleteTaskUseCase.swift

import Foundation

/// タスク完了ユースケースのプロトコル
protocol CompleteTaskUseCaseProtocol {
    func execute(task: TaskEntity, groupCode: String)
}

/// 実装：タスクの完了状態を更新して保存する
final class CompleteTaskUseCase: CompleteTaskUseCaseProtocol {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(task: TaskEntity, groupCode: String) {
        let completedTask = task.asCompleted()
        repository.updateTask(completedTask, groupCode: groupCode)
    }
}
