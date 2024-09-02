//
//  AuthManager.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var userId: String?
    @Published var username: String?
    @Published var groupCode: String?
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    private init() {
           // FirebaseAppが設定されていることを確認
           if FirebaseApp.app() == nil {
               FirebaseApp.configure()
           }
           setupAuthStateListener()
       }
    
    private func joinExistingGroup(groupRef: DocumentReference, username: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
            groupRef.updateData([
                "members": FieldValue.arrayUnion([userId])
            ]) { [weak self] err in
                if let err = err {
                    print("Error updating group: \(err.localizedDescription)")
                    completion(.failure(err))
                } else {
                    print("User successfully added to group")
                    self?.createOrUpdateUserDocument(userId: userId, username: username, groupCode: groupRef.documentID, completion: completion)
                }
            }
        }

        private func createNewGroup(groupCode: String, username: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
            let groupRef = db.collection("groups").document(groupCode)

            let newGroup = [
                "createdAt": FieldValue.serverTimestamp(),
                "members": [userId]
            ] as [String : Any]

            groupRef.setData(newGroup) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self?.createOrUpdateUserDocument(userId: userId, username: username, groupCode: groupCode, completion: completion)
                }
            }
        }

        private func createOrUpdateUserDocument(userId: String, username: String, groupCode: String, completion: @escaping (Result<String, Error>) -> Void) {
            let userRef = db.collection("users").document(userId)

            userRef.getDocument { [weak self] (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                var userData: [String: Any] = [
                    "username": username,
                    "groupCode": groupCode,
                    "lastUpdated": Timestamp()
                ]

                if let document = document, document.exists {
                    // Update existing document
                    userRef.updateData(userData) { error in
                        if let error = error {
                            print("Error updating user document: \(error.localizedDescription)")
                            completion(.failure(error))
                        } else {
                            print("User document successfully updated")
                            self?.updateLocalUserData(username: username, groupCode: groupCode)
                            completion(.success(groupCode))
                        }
                    }
                } else {
                    // Create new document
                    userData["createdAt"] = Timestamp()
                    userRef.setData(userData) { error in
                        if let error = error {
                            print("Error creating user document: \(error.localizedDescription)")
                            completion(.failure(error))
                        } else {
                            print("User document successfully created")
                            self?.updateLocalUserData(username: username, groupCode: groupCode)
                            completion(.success(groupCode))
                        }
                    }
                }
            }
        }

        private func updateLocalUserData(username: String, groupCode: String) {
            DispatchQueue.main.async {
                self.username = username
                self.groupCode = groupCode
            }
        }

    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.userId = user?.uid
            }
        }
    }

    func signInAnonymously(completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signInAnonymously { [weak self] (authResult, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user after anonymous sign in"])))
                return
            }
            
            self?.userId = user.uid
            self?.isAuthenticated = true
            
            self?.createOrUpdateUserDocument(for: user) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func joinOrCreateGroup(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }

        let groupRef = db.collection("groups").document(groupCode)

        groupRef.getDocument { [weak self] (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                self?.joinExistingGroup(groupRef: groupRef, username: username, userId: userId, completion: completion)
            } else {
                self?.createNewGroup(groupCode: groupCode, username: username, userId: userId, completion: completion)
            }
        }
    }

    private func createOrUpdateUserDocument(for user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                userRef.updateData([
                    "lastSignIn": Timestamp()
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                let userData: [String: Any] = [
                    "createdAt": Timestamp(),
                    "lastSignIn": Timestamp()
                ]
                
                userRef.setData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

  

   

    private func updateUserDocument(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(userId)

        userRef.updateData([
            "username": username,
            "groupCode": groupCode,
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating user document: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User document successfully updated with group code")
                completion(.success(()))
            }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async { [weak self] in
                self?.isAuthenticated = false
                self?.userId = nil
                self?.username = nil
                self?.groupCode = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// MARK: - User name validation
extension AuthManager {
    func checkUserExists(username: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error checking user: \(err)")
                completion(false, err)
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    func joinOrCreateGroupWithUsernameCheck(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        checkUserExists(username: username) { [weak self] exists, error in
            if let error = error {
                completion(.failure(error))
            } else if exists {
                completion(.failure(NSError(domain: "AuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "この名前は既に使用されています。名前を書き換えてください"])))
            } else {
                self?.joinOrCreateGroup(groupCode: groupCode, username: username, completion: completion)
            }
        }
    }
}

// MARK: - Local Username Management
extension AuthManager {
    func checkUserExistsLocally(username: String) -> Bool {
        return UserDefaults.standard.string(forKey: "savedUsername") == username
    }

    func saveUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: "savedUsername")
    }

    func getLocalUsername() -> String? {
        return UserDefaults.standard.string(forKey: "savedUsername")
    }

    func joinOrCreateGroupWithLocalUsernameCheck(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        if checkUserExistsLocally(username: username) || getLocalUsername() == nil {
            joinOrCreateGroup(groupCode: groupCode, username: username) { result in
                switch result {
                case .success(let groupCode):
                    self.saveUsername(username)
                    completion(.success(groupCode))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(NSError(domain: "AuthManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "この端末では別の名前が登録されています。"])))
        }
    }
}
