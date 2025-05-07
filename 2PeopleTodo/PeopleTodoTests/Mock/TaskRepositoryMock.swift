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

    func observeTasks(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration {
        fatalError("observeTasks is not used in this test")
    }

    func addTask(_ task: TaskEntity, groupCode: String) {
        self.addedTask = task
        self.addedGroupCode = groupCode
    }

    func updateTask(_ task: TaskEntity, groupCode: String) {
        fatalError("updateTask is not used in this test")
    }

    func deleteTask(_ task: TaskEntity, groupCode: String) {
        fatalError("deleteTask is not used in this test")
    }
}
