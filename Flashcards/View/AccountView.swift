//
//  ProfileView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var showLoginSheet = false
    @State private var showSignupSheet = false
    
    var body: some View {
        VStack(spacing: 10) {
            if authViewModel.isAuthenticated {
                Text("\(authViewModel.currentUserEmail)")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(15)

                Button {
                    authViewModel.logOut()
                } label: {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                }
                
                Spacer()

            } else {
                Button {
                    showLoginSheet = true
                } label: {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                }
                
                Button {
                    showSignupSheet = true
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .padding()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                }
                
                Spacer()
            }
            
        }
        .padding()
        .navigationTitle("Account")
        .sheet(isPresented: $showLoginSheet) {
            LoginSignupSheet(isSignup: false, authViewModel: authViewModel)
        }
        .sheet(isPresented: $showSignupSheet) {
            LoginSignupSheet(isSignup: true, authViewModel: authViewModel)
        }
    }
}


#Preview {
    AccountView()
}
