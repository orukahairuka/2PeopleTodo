//
//  CreateOrUpdateUserUseCaseTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import XCTest
@testable import PeopleTodo

final class CreateOrUpdateUserUseCaseTests: XCTestCase {
    func testExecute_success() {
        let mock = GroupRepositoryMock()
        mock.createOrUpdateUserResult = .success(())

        let useCase = CreateOrUpdateUserUseCaseImpl(repository: mock)

        let expectation = self.expectation(description: "Create or update user success")
        useCase.execute(userId: "user123", username: "Erika", groupCode: "groupX") { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testExecute_failure() {
        let mock = GroupRepositoryMock()
        mock.createOrUpdateUserResult = .failure(NSError(domain: "Test", code: 888, userInfo: nil))

        let useCase = CreateOrUpdateUserUseCaseImpl(repository: mock)

        let expectation = self.expectation(description: "Create or update user failure")
        useCase.execute(userId: "user123", username: "Erika", groupCode: "groupX") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 888)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

