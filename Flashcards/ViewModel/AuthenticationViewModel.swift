//
//  AuthenticationViewModel.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 10.03.25.
//

import SwiftUI
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false {
        didSet {
            if isAuthenticated {
                self.currentUserEmail = authManager.user?.email ?? ""
            }
        }
    }
    @Published var currentUserEmail = ""

    private var authManager = AuthenticationManager()
    
    init() {
        self.isAuthenticated = authManager.user != nil
    }

    func signUp(completion: @escaping (Bool, String?) -> Void) {
        authManager.signUp(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.isAuthenticated = true
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func logIn(completion: @escaping (Bool, String?) -> Void) {
        authManager.logIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.isAuthenticated = true
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func logOut() {
        authManager.logOut { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.isAuthenticated = false
                case .failure(let error):
                    print("Logout error: \(error.localizedDescription)")
                }
            }
        }
    }
}
