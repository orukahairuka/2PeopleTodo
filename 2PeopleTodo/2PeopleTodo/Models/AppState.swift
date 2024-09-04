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
    @Published var isAuthenticated = false
    @Published var groupCode: String?
    @Published var username: String?
    @Published var isExistingUser = false
    @Published var userId: String?
    @Published var isFirebaseInitialized = false
    
    private var db = Firestore.firestore()
    private let auth = Auth.auth()
    
    init() {
        setupAuthStateListener()
        initializeFirebase()
    }
    
    private func initializeFirebase() {
        if FirebaseApp.app() == nil {
            do {
                FirebaseApp.configure()
                self.db = Firestore.firestore()
                self.isFirebaseInitialized = true
                print("Firebase initialized successfully")
            } catch {
                print("Error initializing Firebase: \(error.localizedDescription)")
                self.isFirebaseInitialized = false
                // ここでユーザーに通知を表示するなどの処理を追加
            }
        } else {
            self.db = Firestore.firestore()
            self.isFirebaseInitialized = true
        }
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
        if auth.currentUser == nil {
            auth.signInAnonymously { [weak self] authResult, error in
                if let user = authResult?.user {
                    self?.userId = user.uid
                    completion(true)
                } else {
                    print("匿名認証に失敗しました: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        } else {
            userId = auth.currentUser?.uid
            completion(true)
        }
    }
    
    func saveUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: "savedUsername")
    }
    
    func loadSavedUsername() -> String? {
        return UserDefaults.standard.string(forKey: "savedUsername")
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.userId = user?.uid
            }
        }
    }
    
    func signInAnonymously(completion: @escaping (Bool, String?) -> Void) {
        auth.signInAnonymously { [weak self] authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                completion(false, "Failed to get user after anonymous sign in")
                return
            }
            
            self?.userId = user.uid
            self?.isAuthenticated = true
            completion(true, nil)
        }
    }
    
    func updateUserDocument(userId: String, data: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                userRef.updateData(data) { error in
                    if let error = error {
                        completion(false, "Error updating user document: \(error.localizedDescription)")
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                // ドキュメントが存在しない場合は作成する
                userRef.setData(data) { error in
                    if let error = error {
                        completion(false, "Error creating user document: \(error.localizedDescription)")
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func joinOrCreateGroup(groupCode: String, username: String, isCreating: Bool, completion: @escaping (Bool, String?) -> Void) {
        AuthManager.shared.joinOrCreateGroupWithLocalUsernameCheck(groupCode: groupCode, username: username, isCreating: isCreating) { result in
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
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            completion(false)
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User document already exists")
                completion(true)
            } else {
                // ユーザードキュメントが存在しない場合、新しく作成する
                let userData: [String: Any] = [
                    "createdAt": FieldValue.serverTimestamp(),
                    // 他の初期ユーザーデータをここに追加
                ]
                userRef.setData(userData) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("User document created successfully")
                        completion(true)
                    }
                }
            }
        }
    }
    
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
}
