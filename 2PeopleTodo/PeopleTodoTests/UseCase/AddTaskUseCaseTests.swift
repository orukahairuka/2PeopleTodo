//
//  PeopleTodoTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import XCTest
@testable import PeopleTodo

//タスクが正しく追加されるかをテストするユニットケース
final class AddTaskUseCaseTests: XCTestCase {

    func test_addTask_savesTaskWithCorrectValues() {
        // Arrange
        let mockRepository = TaskRepositoryMock()
        let useCase = AddTaskUseCase(repository: mockRepository)

        // Act
        useCase.execute(
            title: "買い物に行く",
            groupCode: "group123",
            createdBy: "Erika",
            userId: "user123"
        )

        // Assert
        XCTAssertEqual(mockRepository.addedGroupCode, "group123") // グループコードが一致しているか
        XCTAssertEqual(mockRepository.addedTask?.title, "買い物に行く") // タイトルが一致しているか
        XCTAssertEqual(mockRepository.addedTask?.createdBy, "Erika") // 作成者が一致しているか
        XCTAssertEqual(mockRepository.addedTask?.userId, "user123") // ユーザーIDが一致しているか
        XCTAssertFalse(mockRepository.addedTask?.isCompleted ?? true) // isCompleted が false か
    }
}
