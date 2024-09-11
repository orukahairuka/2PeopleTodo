//
//  AppState.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

class AppState: ObservableObject {
    @Published var isAuthenticated = false  // ここだけにする
        @Published var groupCode: String?
        @Published var username: String?
        @Published var isExistingUser = false
        @Published var userId: String?
        @Published var isFirebaseInitialized = false

        private var db: Firestore?
        private let auth = Auth.auth()
        private let maxRetries = 5
        private let retryDelay: TimeInterval = 2.0
        
        init() {
            setupAuthStateListener()
            initializeFirebase()
        }
        
        private func setupAuthStateListener() {
            auth.addStateDidChangeListener { [weak self] _, user in
                DispatchQueue.main.async {
                    self?.isAuthenticated = user != nil
                    self?.userId = user?.uid
                }
            }
        }
        
        private func initializeFirebase() {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            
            self.db = Firestore.firestore()
            self.isFirebaseInitialized = true
            print("Firebase initialized successfully")
        }
    
    private func retryOperation<T>(_ operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void, completion: @escaping (Result<T, Error>) -> Void) {
        func attempt(retriesLeft: Int) {
            operation { result in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    if retriesLeft > 0 && (error.isPermissionError || error.isNetworkError) {
                        print("Operation failed, retrying... (\(retriesLeft) attempts left)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.retryDelay) {
                            attempt(retriesLeft: retriesLeft - 1)
                        }
                    } else {
                        completion(result)
                    }
                }
            }
        }
        
        attempt(retriesLeft: maxRetries)
    }
    
    func checkAuthenticationStatus(completion: @escaping (Bool) -> Void) {
        guard isFirebaseInitialized else {
            print("Firebase is not initialized")
            completion(false)
            return
        }
        
        if let user = Auth.auth().currentUser {
            print("User is signed in with UID: \(user.uid)")
            completion(true)
        } else {
            print("No user is signed in.")
            ensureAnonymousAuth(completion: completion)
        }
    }
    
    func ensureAnonymousAuth(completion: @escaping (Bool) -> Void) {
        retryOperation { (operationCompletion: @escaping (Result<Bool, Error>) -> Void) in
            if self.auth.currentUser == nil {
                self.auth.signInAnonymously { authResult, error in
                    if let user = authResult?.user {
                        self.userId = user.uid
                        operationCompletion(.success(true))
                    } else {
                        operationCompletion(.failure(error ?? NSError(domain: "AppState", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error during anonymous auth"])))
                    }
                }
            } else {
                self.userId = self.auth.currentUser?.uid
                operationCompletion(.success(true))
            }
        } completion: { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Failed to ensure anonymous auth after retries: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func joinOrCreateGroup(groupCode: String, username: String, isCreating: Bool, completion: @escaping (Bool, String?) -> Void) {
        retryOperation { (operationCompletion: @escaping (Result<String, Error>) -> Void) in
            AuthManager.shared.joinOrCreateGroupWithLocalUsernameCheck(groupCode: groupCode, username: username, isCreating: isCreating) { result in
                operationCompletion(result)
            }
        } completion: { result in
            switch result {
            case .success(let groupCode):
                DispatchQueue.main.async {
                    self.groupCode = groupCode
                    self.username = username
                    self.isAuthenticated = true
                    AuthManager.shared.saveUsername(username)
                    completion(true, nil)
                }
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.groupCode = nil
                self.username = nil
                self.isExistingUser = false
                self.userId = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func ensureUserDocument(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, let db = self.db else {
            print("No authenticated user or Firestore not initialized")
            completion(false)
            return
        }
        
        retryOperation { (operationCompletion: @escaping (Result<Bool, Error>) -> Void) in
            let userRef = db.collection("users").document(userId)
            userRef.getDocument { (document, error) in
                if let error = error {
                    operationCompletion(.failure(error))
                    return
                }
                
                if let document = document, document.exists {
                    print("User document already exists")
                    operationCompletion(.success(true))
                } else {
                    let userData: [String: Any] = [
                        "createdAt": FieldValue.serverTimestamp(),
                    ]
                    userRef.setData(userData) { error in
                        if let error = error {
                            operationCompletion(.failure(error))
                        } else {
                            print("User document created successfully")
                            operationCompletion(.success(true))
                        }
                    }
                }
            }
        } completion: { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Failed to ensure user document: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func checkUserExists(username: String, completion: @escaping (Bool) -> Void) {
        guard let db = self.db else {
            print("Firestore not initialized")
            completion(false)
            return
        }
        
        retryOperation { (operationCompletion: @escaping (Result<Bool, Error>) -> Void) in
            let userRef = db.collection("users").document(username)
            userRef.getDocument { document, error in
                if let error = error {
                    operationCompletion(.failure(error))
                } else if let document = document, document.exists {
                    operationCompletion(.success(true))
                } else {
                    operationCompletion(.success(false))
                }
            }
        } completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exists):
                    self.isExistingUser = exists
                    if exists {
                        self.username = username
                    }
                    completion(exists)
                case .failure(let error):
                    print("Failed to check user existence: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}

