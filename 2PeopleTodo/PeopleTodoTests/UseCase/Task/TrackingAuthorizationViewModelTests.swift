//
//  TrackingAuthorizationViewModelTests.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation
import XCTest
@testable import PeopleTodo

final class TrackingAuthorizationViewModelTests: XCTestCase {

    func test_checkAuthorizationStatus_authorized_setsTrue() {
        let mockUseCase = TrackingAuthorizationUseCaseMock()
        mockUseCase.statusToReturn = .authorized

        let viewModel = TrackingAuthorizationViewModel(useCase: mockUseCase)
        viewModel.checkAuthorizationStatus()

        XCTAssertEqual(viewModel.isTrackingAuthorized, true)
    }

    func test_checkAuthorizationStatus_denied_setsFalse() {
        let mockUseCase = TrackingAuthorizationUseCaseMock()
        mockUseCase.statusToReturn = .denied

        let viewModel = TrackingAuthorizationViewModel(useCase: mockUseCase)
        viewModel.checkAuthorizationStatus()

        XCTAssertEqual(viewModel.isTrackingAuthorized, false)
    }

    func test_checkAuthorizationStatus_notDetermined_requestsAuthorization() {
        let mockUseCase = TrackingAuthorizationUseCaseMock()
        mockUseCase.statusToReturn = .authorized  // リクエスト後の想定レスポンス

        let viewModel = TrackingAuthorizationViewModel(useCase: mockUseCase)
        let expectation = XCTestExpectation(description: "Async request completed")

        viewModel.requestAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(viewModel.isTrackingAuthorized, true)
            XCTAssertTrue(mockUseCase.didCallRequestAuthorization)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
