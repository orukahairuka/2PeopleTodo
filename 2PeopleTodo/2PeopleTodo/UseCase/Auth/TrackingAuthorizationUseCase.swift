//
//  TrackingAuthorizationUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import AppTrackingTransparency

final class TrackingAuthorizationUseCase: TrackingAuthorizationUseCaseProtocol {
    func getAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }

    func requestAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            completion(status)
        }
    }
}

