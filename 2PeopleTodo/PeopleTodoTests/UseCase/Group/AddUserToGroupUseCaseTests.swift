//
//  AddUserToGroupUseCaseTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import XCTest
@testable import PeopleTodo

final class AddUserToGroupUseCaseTests: XCTestCase {
    func testExecute_success() {
        // モック設定
        let mock = GroupRepositoryMock()
        mock.addUserToGroupResult = .success(())

        // UseCase作成
        let useCase = AddUserToGroupUseCaseImpl(repository: mock)

        // テスト実行
        let expectation = self.expectation(description: "Add user success")
        useCase.execute(groupCode: "testCode", userId: "user123") { result in
            switch result {
            case .success:
                // 成功を期待
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testExecute_failure() {
        // モック設定
        let mock = GroupRepositoryMock()
        mock.addUserToGroupResult = .failure(NSError(domain: "Test", code: 999, userInfo: nil))

        // UseCase作成
        let useCase = AddUserToGroupUseCaseImpl(repository: mock)

        // テスト実行
        let expectation = self.expectation(description: "Add user failure")
        useCase.execute(groupCode: "testCode", userId: "user123") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 999)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
