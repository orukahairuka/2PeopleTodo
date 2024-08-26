//
//  AppState.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseFirestore

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var groupCode: String?
    @Published var username: String?
    @Published var isExistingUser = false

    private let db = Firestore.firestore()

    func checkUserExists(username: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(username)
        userRef.getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    self?.isExistingUser = true
                    self?.username = username
                    completion(true)
                } else {
                    self?.isExistingUser = false
                    completion(false)
                }
            }
        }
    }

    func joinOrCreateGroup(groupCode: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        AuthManager.shared.joinOrCreateGroup(groupCode: groupCode, username: username) { [weak self] result in
            switch result {
            case .success(let groupCode):
                DispatchQueue.main.async {
                    self?.groupCode = groupCode
                    self?.username = username
                    self?.isAuthenticated = true
                    self?.saveUsername(username)
                    completion(true, nil)
                }
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    private func addUserToGroup(groupRef: DocumentReference, username: String, completion: @escaping (Bool, String?) -> Void) {
        groupRef.updateData([
            "members": FieldValue.arrayUnion([username])
        ]) { error in
            if let error = error {
                completion(false, "グループへの追加に失敗しました: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }

    private func createNewGroup(groupRef: DocumentReference, username: String, completion: @escaping (Bool, String?) -> Void) {
        groupRef.setData([
            "createdAt": Timestamp(),
            "members": [username]
        ]) { error in
            if let error = error {
                completion(false, "グループの作成に失敗しました: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }

    private func updateUserDocument(username: String, groupCode: String, completion: @escaping (Bool, String?) -> Void) {
        let userRef = db.collection("users").document(username)
        userRef.setData([
            "groupCode": groupCode,
            "lastUpdated": Timestamp()
        ], merge: true) { error in
            if let error = error {
                completion(false, "ユーザー情報の更新に失敗しました: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }

    func signOut() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.groupCode = nil
            self.username = nil
            self.isExistingUser = false
        }
    }
}

extension AppState {
    func saveUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: "savedUsername")
    }
}
