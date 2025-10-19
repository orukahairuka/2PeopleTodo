//
//  DeleteTaskUseCaseTests.swift
//  PeopleTodoTests
//
//  Created by Claude Code
//

import XCTest
@testable import PeopleTodo

/// DeleteTaskUseCase のユニットテスト
final class DeleteTaskUseCaseTests: XCTestCase {

    /// タスク削除ユースケースが正しくリポジトリのdeleteTaskメソッドを呼び出すかを検証
    func test_deleteTask_removesTaskSuccessfully() {
        // Arrange: テスト用のモックリポジトリとユースケースを準備
        let mockRepository = TaskRepositoryMock()
        let useCase = DeleteTaskUseCase(repository: mockRepository)

        let task = TaskEntity(
            id: "task123",
            title: "削除するタスク",
            isCompleted: false,
            completedAt: nil,
            createdBy: "Erika",
            userId: "user123"
        )
        let groupCode = "group456"

        // Act: タスクを削除
        useCase.execute(task: task, groupCode: groupCode)

        // Assert: 正しいパラメータでdeleteTaskが呼ばれたか検証
        XCTAssertEqual(mockRepository.deletedGroupCode, "group456", "グループコードが一致しているか")
        XCTAssertEqual(mockRepository.deletedTask?.id, "task123", "削除されたタスクのIDが一致しているか")
        XCTAssertEqual(mockRepository.deletedTask?.title, "削除するタスク", "削除されたタスクのタイトルが一致しているか")
        XCTAssertEqual(mockRepository.deletedTask?.createdBy, "Erika", "削除されたタスクの作成者が一致しているか")
    }

    /// 完了済みタスクも削除できることを検証
    func test_deleteTask_removesCompletedTask() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        let useCase = DeleteTaskUseCase(repository: mockRepository)

        let completedTask = TaskEntity(
            id: "completed123",
            title: "完了したタスク",
            isCompleted: true,
            completedAt: Date(),
            createdBy: "User1",
            userId: "user1"
        )
        let groupCode = "groupXYZ"

        // Act
        useCase.execute(task: completedTask, groupCode: groupCode)

        // Assert
        XCTAssertEqual(mockRepository.deletedGroupCode, "groupXYZ")
        XCTAssertEqual(mockRepository.deletedTask?.id, "completed123")
        XCTAssertTrue(mockRepository.deletedTask?.isCompleted ?? false, "完了済みタスクも削除できるか")
    }

    /// 複数回削除を実行しても最後の削除内容が記録されることを検証
    func test_deleteTask_multipleDeletes_recordsLastDelete() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        let useCase = DeleteTaskUseCase(repository: mockRepository)

        let task1 = TaskEntity(id: "task1", title: "1つ目", isCompleted: false, completedAt: nil, createdBy: "User1", userId: "u1")
        let task2 = TaskEntity(id: "task2", title: "2つ目", isCompleted: false, completedAt: nil, createdBy: "User2", userId: "u2")

        // Act: 2回削除を実行
        useCase.execute(task: task1, groupCode: "group1")
        useCase.execute(task: task2, groupCode: "group2")

        // Assert: 最後に削除されたタスクが記録されているか
        XCTAssertEqual(mockRepository.deletedTask?.id, "task2", "最後に削除されたタスクが記録されているか")
        XCTAssertEqual(mockRepository.deletedGroupCode, "group2", "最後のグループコードが記録されているか")
    }
}
