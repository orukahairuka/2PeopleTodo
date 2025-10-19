//
//  TaskRepositoryMock.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import Foundation
import FirebaseFirestore

@testable import PeopleTodo
class TaskRepositoryMock: TaskRepositoryProtocol {
    var addedTask: TaskEntity?
    var addedGroupCode: String?
    var updatedTask: TaskEntity?
    var updatedGroupCode: String?
    var deletedTask: TaskEntity?
    var deletedGroupCode: String?
    var shouldFailDelete: Bool = false

    // observeTasks用
    var tasksToReturn: [TaskEntity] = []
    var observeGroupCode: String?
    var observeCallCount: Int = 0

    func observeTasks(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration {
        self.observeGroupCode = groupCode
        self.observeCallCount += 1

        // テスト用に即座にタスクリストを返す
        onUpdate(tasksToReturn)

        // ダミーのListenerRegistrationを返す
        return MockListenerRegistration()
    }

    func addTask(_ task: TaskEntity, groupCode: String) {
        self.addedTask = task
        self.addedGroupCode = groupCode
    }

    func updateTask(_ task: TaskEntity, groupCode: String) {
        self.updatedTask = task
        self.updatedGroupCode = groupCode
    }

    func deleteTask(_ task: TaskEntity, groupCode: String) {
        self.deletedTask = task
        self.deletedGroupCode = groupCode
    }
}

// MockのListenerRegistration
class MockListenerRegistration: NSObject, ListenerRegistration {
    func remove() {
        // テスト用の空実装
    }
}
