//
//  PasswordPromptView.swift
//  oneLock
//
//  Created by wesley on 2025/3/2.
//


import SwiftUI

struct PasswordPromptView: View {
        @Binding var isPresented: Bool
        var onPasswordSubmit: (String) -> Void
        @State private var password: String = ""
        
        var body: some View {
                VStack(spacing: 20) {
                        Text("Enter Password")
                                .font(.headline)
                        
                        SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        
                        HStack {
                                Button("Cancel") {
                                        isPresented = false
                                }
                                Spacer()
                                Button("Confirm") {
                                        onPasswordSubmit(password)
                                        password = ""
                                        isPresented = false
                                }
                        }
                        .padding(.horizontal)
                }
                .padding()
        }
}
