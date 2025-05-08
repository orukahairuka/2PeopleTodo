//
//  CompleteTaskUseCaseTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import Foundation
import FirebaseFirestore
import XCTest
@testable import PeopleTodo

/// CompleteTaskUseCase のユニットテスト
final class CompleteTaskUseCaseTests: XCTestCase {

    /// タスク完了ユースケースが正しくタスクの状態を更新するかどうかを検証
    func test_completeTask_setsIsCompletedTrue_andSetsCompletedAt() {
        // Arrange
        let mockRepository = TaskRepositoryMock() // リポジトリのモックを用意
        let useCase = CompleteTaskUseCase(repository: mockRepository) // ユースケースにモックを注入
        let task = TaskEntity(
            id: "abc123",
            title: "やること",
            isCompleted: false,     // 最初は未完了
            completedAt: nil,       // 完了日時も未設定
            createdBy: "user1",
            userId: "user1"
        )

        // Act
        useCase.execute(task: task, groupCode: "groupABC")

        // Assert
        XCTAssertEqual(mockRepository.updatedGroupCode, "groupABC") // 正しいグループに保存されたか
        XCTAssertTrue(mockRepository.updatedTask?.isCompleted ?? false) // 完了フラグが true に変わったか
        XCTAssertNotNil(mockRepository.updatedTask?.completedAt) // 完了日時が設定されたか
    }
}
