//
//  TrackingAuthorizationViewModel.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation
import AppTrackingTransparency
import UIKit

final class TrackingAuthorizationViewModel: ObservableObject {
    @Published var isTrackingAuthorized: Bool? = nil

    func checkAuthorizationStatus() {
        let status = ATTrackingManager.trackingAuthorizationStatus
        switch status {
        case .authorized:
            isTrackingAuthorized = true
        case .denied, .restricted:
            isTrackingAuthorized = false
        case .notDetermined:
            requestAuthorization()
        @unknown default:
            isTrackingAuthorized = false
        }
    }

    func requestAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.isTrackingAuthorized = true
                case .denied, .restricted, .notDetermined, @unknown default:
                    self.isTrackingAuthorized = false
                }
            }
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
