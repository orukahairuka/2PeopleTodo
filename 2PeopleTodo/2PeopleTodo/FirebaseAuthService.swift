//
//  FirebaseAuthService.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import FirebaseAuth
import FirebaseCore

protocol AuthServiceProtocol {
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void)
    func signOut() -> Result<Void, Error>
    func addAuthStateListener(_ callback: @escaping (User?) -> Void)
    var currentUser: User? { get }
}


final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private let auth = Auth.auth()

    private init() {
        initializeFirebase()
    }

    private func initializeFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        print("Firebase initialized")
    }

    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        auth.signInAnonymously { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown authentication error."])))
            }
        }
    }

    func signOut() -> Result<Void, Error> {
        do {
            try auth.signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func addAuthStateListener(_ callback: @escaping (User?) -> Void) {
        auth.addStateDidChangeListener { _, user in
            callback(user)
        }
    }

    var currentUser: User? {
        return auth.currentUser
    }
}
