//
//  AuthManager.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var groupId: String?
    private var db = Firestore.firestore()

    func signIn(email: String, password: String, groupPassword: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let user = authResult?.user {
                self?.verifyGroupPassword(userId: user.uid, groupPassword: groupPassword) { success, groupId, error in
                    if success, let groupId = groupId {
                        DispatchQueue.main.async {
                            self?.currentUser = user
                            self?.groupId = groupId
                            self?.isAuthenticated = true
                            completion(true, nil)
                        }
                    } else {
                        completion(false, error ?? "グループパスワードが一致しません")
                    }
                }
            } else {
                completion(false, error?.localizedDescription ?? "ログインに失敗しました")
            }
        }
    }

    func signUp(email: String, password: String, groupPassword: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let user = authResult?.user {
                self?.createOrJoinGroup(userId: user.uid, groupPassword: groupPassword) { success, groupId, error in
                    if success, let groupId = groupId {
                        DispatchQueue.main.async {
                            self?.currentUser = user
                            self?.groupId = groupId
                            self?.isAuthenticated = true
                            completion(true, nil)
                        }
                    } else {
                        completion(false, error ?? "グループの作成に失敗しました")
                    }
                }
            } else {
                completion(false, error?.localizedDescription ?? "新規登録に失敗しました")
            }
        }
    }

    private func verifyGroupPassword(userId: String, groupPassword: String, completion: @escaping (Bool, String?, String?) -> Void) {
        let groupId = hashGroupPassword(groupPassword)
        db.collection("groups").document(groupId).getDocument { document, error in
            if let document = document, document.exists {
                var members = document.data()?["members"] as? [String] ?? []
                if !members.contains(userId) {
                    members.append(userId)
                    self.db.collection("groups").document(groupId).updateData(["members": members])
                }
                completion(true, groupId, nil)
            } else {
                completion(false, nil, "グループが見つかりません")
            }
        }
    }

    private func createOrJoinGroup(userId: String, groupPassword: String, completion: @escaping (Bool, String?, String?) -> Void) {
        let groupId = hashGroupPassword(groupPassword)
        db.collection("groups").document(groupId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                var members = document.data()?["members"] as? [String] ?? []
                if !members.contains(userId) {
                    members.append(userId)
                    self?.db.collection("groups").document(groupId).updateData(["members": members]) { error in
                        if let error = error {
                            completion(false, nil, error.localizedDescription)
                        } else {
                            completion(true, groupId, nil)
                        }
                    }
                } else {
                    completion(true, groupId, nil)
                }
            } else {
                self?.db.collection("groups").document(groupId).setData([
                    "members": [userId],
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        completion(false, nil, error.localizedDescription)
                    } else {
                        completion(true, groupId, nil)
                    }
                }
            }
        }
    }

    private func hashGroupPassword(_ password: String) -> String {
        // 注意: 実際のアプリケーションではより安全なハッシュ関数を使用してください
        return password.data(using: .utf8)?.base64EncodedString() ?? ""
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
                self.groupId = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
