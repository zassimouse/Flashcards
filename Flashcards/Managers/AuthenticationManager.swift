//
//  FirebaseAuthManager.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 10.03.25.
//

import Foundation
import FirebaseAuth

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    var user: User?
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    var userEmail: String? {
        user?.email
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.user = user
                completion(.success(user))
            }
        }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self.user = user
                completion(.success(user))
            }
        }
    }
    
    func logOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            self.user = nil
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
