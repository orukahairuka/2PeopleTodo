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
        let groupRef = db.collection("groups").document(groupCode)

        groupRef.getDocument { [weak self] (document, error) in
            if let error = error {
                completion(false, "エラーが発生しました: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                // グループが存在する場合、ユーザーを追加
                self?.addUserToGroup(groupRef: groupRef, username: username) { success, error in
                    if success {
                        self?.updateUserDocument(username: username, groupCode: groupCode) { success, error in
                            DispatchQueue.main.async {
                                self?.groupCode = groupCode
                                self?.username = username
                                self?.isAuthenticated = true
                                completion(success, error)
                            }
                        }
                    } else {
                        completion(false, error)
                    }
                }
            } else {
                // 新しいグループを作成
                self?.createNewGroup(groupRef: groupRef, username: username) { success, error in
                    if success {
                        self?.updateUserDocument(username: username, groupCode: groupCode) { success, error in
                            DispatchQueue.main.async {
                                self?.groupCode = groupCode
                                self?.username = username
                                self?.isAuthenticated = true
                                completion(success, error)
                            }
                        }
                    } else {
                        completion(false, error)
                    }
                }
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
