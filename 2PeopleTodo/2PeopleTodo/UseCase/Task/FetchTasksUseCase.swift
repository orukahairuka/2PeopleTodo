//
//  FetchTasksUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// FetchTasksUseCase.swift
import Foundation
import FirebaseFirestore

/// タスク取得ユースケースのプロトコル
protocol FetchTasksUseCaseProtocol {
    func execute(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration
}

/// Firestore を利用したタスク取得ユースケースの実装
class FetchTasksUseCase: FetchTasksUseCaseProtocol {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration {
        return repository.observeTasks(groupCode: groupCode, onUpdate: onUpdate)
    }
}
