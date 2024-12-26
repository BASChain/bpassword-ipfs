//
//  AccountDetailView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//
import SwiftUI

struct AccountDetailView: View {
        let account: Account
        @State private var isPasswordVisible: Bool = false
        
        var body: some View {
                VStack(spacing: 20) {
                        Text("Platform: \(account.platform)")
                                .font(.title)
                        Text("Username: \(account.username)")
                                .font(.headline)
                        ZStack {
                                Text(account.password)
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .opacity(isPasswordVisible ? 1.0 : 0.0) // 密码默认隐藏
                                
                                if !isPasswordVisible {
                                        Color.black.opacity(0.7)
                                                .cornerRadius(5)
                                        Text("Password Hidden")
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                }
                        }
                        .frame(height: 50)
                        .padding()
                        
                        Button(action: {}) {
                                Text("Press and Hold to View Password")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                        }
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                withAnimation {
                                        isPasswordVisible = isPressing
                                }
                        }) {}
                        
                        Spacer()
                }
                .padding()
                .navigationTitle("Account Details")
        }
}
