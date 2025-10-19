//
//  FetchTasksUseCaseTests.swift
//  PeopleTodoTests
//
//  Created by Claude Code
//

import XCTest
import FirebaseFirestore
@testable import PeopleTodo

/// FetchTasksUseCase のユニットテスト
final class FetchTasksUseCaseTests: XCTestCase {

    /// タスク取得が正常に動作し、正しいタスクリストが返されることを検証
    func test_fetchTasks_returnsCorrectTasks() {
        // Arrange: モックリポジトリに返すタスクを設定
        let mockRepository = TaskRepositoryMock()

        let task1 = TaskEntity(
            id: "task1",
            title: "買い物に行く",
            isCompleted: false,
            completedAt: nil,
            createdBy: "Erika",
            userId: "user1"
        )
        let task2 = TaskEntity(
            id: "task2",
            title: "掃除をする",
            isCompleted: true,
            completedAt: Date(),
            createdBy: "John",
            userId: "user2"
        )

        mockRepository.tasksToReturn = [task1, task2]

        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act & Assert: タスク取得を実行し、コールバックで正しいタスクが返されるか検証
        var returnedTasks: [TaskEntity] = []
        let listener = useCase.execute(groupCode: "group123") { tasks in
            returnedTasks = tasks
        }

        // Assert
        XCTAssertEqual(mockRepository.observeGroupCode, "group123", "正しいグループコードで取得されているか")
        XCTAssertEqual(returnedTasks.count, 2, "タスク数が正しいか")
        XCTAssertEqual(returnedTasks[0].id, "task1", "1つ目のタスクIDが正しいか")
        XCTAssertEqual(returnedTasks[0].title, "買い物に行く", "1つ目のタスクタイトルが正しいか")
        XCTAssertEqual(returnedTasks[1].id, "task2", "2つ目のタスクIDが正しいか")
        XCTAssertEqual(returnedTasks[1].title, "掃除をする", "2つ目のタスクタイトルが正しいか")

        // Cleanup
        listener.remove()
    }

    /// 空のタスクリストが正しく返されることを検証
    func test_fetchTasks_returnsEmptyList() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        mockRepository.tasksToReturn = [] // 空のタスクリスト

        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act
        var returnedTasks: [TaskEntity] = []
        let listener = useCase.execute(groupCode: "emptyGroup") { tasks in
            returnedTasks = tasks
        }

        // Assert
        XCTAssertEqual(returnedTasks.count, 0, "空のタスクリストが返されるか")
        XCTAssertEqual(mockRepository.observeGroupCode, "emptyGroup", "正しいグループコードで取得されているか")

        // Cleanup
        listener.remove()
    }

    /// リアルタイム更新のシミュレーション（observeTasksが呼ばれることを検証）
    func test_fetchTasks_observeRealtimeUpdates() {
        // Arrange
        let mockRepository = TaskRepositoryMock()

        let initialTasks = [
            TaskEntity(id: "t1", title: "初期タスク", isCompleted: false, completedAt: nil, createdBy: "User1", userId: "u1")
        ]
        mockRepository.tasksToReturn = initialTasks

        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act: observeTasksが呼ばれるか検証
        var updateCallCount = 0
        var latestTasks: [TaskEntity] = []

        let listener = useCase.execute(groupCode: "realtimeGroup") { tasks in
            latestTasks = tasks
            updateCallCount += 1
        }

        // Assert
        XCTAssertEqual(mockRepository.observeCallCount, 1, "observeTasksが1回呼ばれたか")
        XCTAssertEqual(updateCallCount, 1, "onUpdateコールバックが1回呼ばれたか")
        XCTAssertEqual(latestTasks.count, 1, "初期タスクが返されたか")
        XCTAssertEqual(latestTasks[0].title, "初期タスク")

        // Cleanup
        listener.remove()
    }

    /// 複数のタスクが正しい順序で返されることを検証
    func test_fetchTasks_returnsTasksInCorrectOrder() {
        // Arrange
        let mockRepository = TaskRepositoryMock()

        let tasks = [
            TaskEntity(id: "1", title: "1つ目", isCompleted: false, completedAt: nil, createdBy: "A", userId: "a"),
            TaskEntity(id: "2", title: "2つ目", isCompleted: false, completedAt: nil, createdBy: "B", userId: "b"),
            TaskEntity(id: "3", title: "3つ目", isCompleted: true, completedAt: Date(), createdBy: "C", userId: "c")
        ]
        mockRepository.tasksToReturn = tasks

        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act
        var returnedTasks: [TaskEntity] = []
        let listener = useCase.execute(groupCode: "orderGroup") { tasks in
            returnedTasks = tasks
        }

        // Assert: タスクが正しい順序で返されるか
        XCTAssertEqual(returnedTasks.count, 3)
        XCTAssertEqual(returnedTasks[0].id, "1")
        XCTAssertEqual(returnedTasks[1].id, "2")
        XCTAssertEqual(returnedTasks[2].id, "3")
        XCTAssertEqual(returnedTasks[0].title, "1つ目")
        XCTAssertEqual(returnedTasks[1].title, "2つ目")
        XCTAssertEqual(returnedTasks[2].title, "3つ目")

        // Cleanup
        listener.remove()
    }

    /// ListenerRegistrationが正しく返されることを検証
    func test_fetchTasks_returnsListenerRegistration() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        mockRepository.tasksToReturn = []

        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act
        let listener = useCase.execute(groupCode: "listenerGroup") { _ in }

        // Assert: ListenerRegistrationが返されるか
        XCTAssertNotNil(listener, "ListenerRegistrationが返されるか")

        // Cleanup: listenerのremoveメソッドが呼べるか確認
        XCTAssertNoThrow(listener.remove(), "listener.remove()がエラーなく実行できるか")
    }

    /// 異なるグループコードで複数回呼び出しても正しく動作することを検証
    func test_fetchTasks_handlesMultipleGroupCodes() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        let task1 = TaskEntity(id: "t1", title: "グループ1のタスク", isCompleted: false, completedAt: nil, createdBy: "U1", userId: "u1")

        mockRepository.tasksToReturn = [task1]
        let useCase = FetchTasksUseCase(repository: mockRepository)

        // Act: 1回目の取得
        var group1Tasks: [TaskEntity] = []
        let listener1 = useCase.execute(groupCode: "group1") { tasks in
            group1Tasks = tasks
        }

        // 2回目の取得（異なるグループコード）
        let task2 = TaskEntity(id: "t2", title: "グループ2のタスク", isCompleted: false, completedAt: nil, createdBy: "U2", userId: "u2")
        mockRepository.tasksToReturn = [task2]

        var group2Tasks: [TaskEntity] = []
        let listener2 = useCase.execute(groupCode: "group2") { tasks in
            group2Tasks = tasks
        }

        // Assert
        XCTAssertEqual(mockRepository.observeCallCount, 2, "observeTasksが2回呼ばれたか")
        XCTAssertEqual(mockRepository.observeGroupCode, "group2", "最後のグループコードが記録されているか")
        XCTAssertEqual(group2Tasks[0].title, "グループ2のタスク")

        // Cleanup
        listener1.remove()
        listener2.remove()
    }
}
