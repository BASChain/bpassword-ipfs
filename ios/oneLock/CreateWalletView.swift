//
//  CreateWalletView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI
struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var mnemonic: String? = nil
        @EnvironmentObject var appState: AppState // 添加环境对象引用
        var body: some View {
                Text("Has Wallet: \(appState.hasWallet ? "Yes" : "No")")
                VStack {
                        if let mnemonicPhrase = mnemonic {
                                MnemonicView(mnemonic: mnemonicPhrase, password: password).environmentObject(appState)
                        } else {
                                VStack {
                                        Text("Create Wallet")
                                                .font(.title)
                                                .padding()
                                        
                                        SecureField("Enter Password", text: $password)
                                                .textFieldStyle(.roundedBorder)
                                                .padding()
                                        
                                        SecureField("Confirm Password", text: $confirmPassword)
                                                .textFieldStyle(.roundedBorder)
                                                .padding()
                                        
                                        if let error = errorMessage {
                                                Text(error)
                                                        .foregroundColor(.red)
                                                        .padding()
                                        }
                                        
                                        Button("Generate Wallet") {
                                                generateWallet()
                                        }
                                        .padding()
                                }
                        }
                }
                .padding()
        }
        
        private func generateWallet() {
                guard password == confirmPassword else {
                        errorMessage = "Passwords do not match"
                        return
                }
                
                // 调用 SdkUtil 来生成助记词
                if let generatedMnemonic = SdkUtil.shared.generateMnemonic(password:password) {
                        mnemonic = generatedMnemonic
                        errorMessage = nil
                } else {
                        errorMessage = "Failed to generate wallet. Please try again."
                }
        }
}

