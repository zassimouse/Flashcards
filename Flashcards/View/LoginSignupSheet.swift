//
//  LoginSignupSheet.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 10.03.25.
//

import SwiftUI

struct LoginSignupSheet: View {
    let isSignup: Bool
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                TextField("Email", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $authViewModel.password)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 15))

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }

                Button {
                    if isSignup {
                        authViewModel.signUp { success, error in
                            if success {
                                authViewModel.isAuthenticated = true
                                dismiss()
                            } else {
                                errorMessage = error
                            }
                        }
                    } else {
                        authViewModel.logIn { success, error in
                            if success {
                                authViewModel.isAuthenticated = true
                                dismiss()
                            } else {
                                errorMessage = error
                            }
                        }
                    }
                } label: {
                    Text(isSignup ? "Sign Up" : "Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(authViewModel.email.isEmpty || authViewModel.password.count < 6 ? Color.gray : Color.blue)
                        .cornerRadius(15)
                }
                .disabled(authViewModel.email.isEmpty || authViewModel.password.count < 6)

                Spacer()
            }
            .padding()
            .navigationTitle(isSignup ? "Sign Up" : "Log In")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
                authViewModel.email = ""
                authViewModel.password = ""
            })
        }
    }
}


#Preview {
    AccountView()
}
