//
//  FirebaseAuthService.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

//  FirebaseAuthService.swift
//  PeopleTodo

import FirebaseAuth

protocol AuthServiceProtocol {
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void)
    var currentUser: User? { get }
}

final class FirebaseAuthService: AuthServiceProtocol {
    private let auth = Auth.auth()

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

    var currentUser: User? {
        return auth.currentUser
    }
}
