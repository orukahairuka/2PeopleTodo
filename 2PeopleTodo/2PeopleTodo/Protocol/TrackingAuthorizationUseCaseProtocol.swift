//
//  TrackingAuthorizationUseCaseProtocol.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation

protocol TrackingAuthorizationUseCaseProtocol {
    func getAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus
    func requestAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void)
}

