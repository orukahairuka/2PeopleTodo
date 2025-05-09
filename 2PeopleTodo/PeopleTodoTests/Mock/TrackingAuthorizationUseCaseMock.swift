//
//  TrackingAuthorizationUseCaseMock.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation
import AppTrackingTransparency
@testable import PeopleTodo

final class TrackingAuthorizationUseCaseMock: TrackingAuthorizationUseCaseProtocol {
    var statusToReturn: ATTrackingManager.AuthorizationStatus = .notDetermined
    var didCallRequestAuthorization = false

    func getAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        return statusToReturn
    }

    func requestAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        didCallRequestAuthorization = true
        completion(statusToReturn)
    }
}
