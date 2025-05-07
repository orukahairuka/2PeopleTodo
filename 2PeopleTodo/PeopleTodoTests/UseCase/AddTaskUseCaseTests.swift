//
//  PeopleTodoTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import XCTest
@testable import PeopleTodo

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
        XCTAssertEqual(mockRepository.addedGroupCode, "group123")
        XCTAssertEqual(mockRepository.addedTask?.title, "買い物に行く")
        XCTAssertEqual(mockRepository.addedTask?.createdBy, "Erika")
        XCTAssertEqual(mockRepository.addedTask?.userId, "user123")
        XCTAssertFalse(mockRepository.addedTask?.isCompleted ?? true)
    }
}
