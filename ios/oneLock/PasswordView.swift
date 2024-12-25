//
//  PasswordView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//
import SwiftUI
import SwiftData

struct PasswordView: View {
        @EnvironmentObject var appState: AppState
        @State private var password: String = ""

        var body: some View {
                VStack {
                        Text("Enter Password for Wallet")
                            .font(.title)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        Button("Validate") {
                                validatePassword()
                        }
                        .padding()
                }
        }

        private func validatePassword() {
                // Replace this with real validation logic
                if password == "123" { // Example password
                        appState.isPasswordValidated = true
                } else {
                        print("Invalid Password")
                }
        }
}
