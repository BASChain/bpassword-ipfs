//
//  PasswordView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//
import SwiftUI

struct PasswordView: View {
        @EnvironmentObject var appState: AppState
        @State private var password: String = ""
        @State private var errorMessage: String? = nil
        @StateObject private var loadingManager = LoadingManager() // 添加 LoadingManager 实例
        
        var body: some View {
                NavigationView { // 添加 NavigationView
                        ZStack {
                                VStack {
                                        Text("Enter Password for Wallet")
                                                .font(.title)
                                                .padding()
                                        
                                        SecureField("Password", text: $password)
                                                .textFieldStyle(.roundedBorder)
                                                .padding()
                                        
                                        if let error = errorMessage {
                                                Text(error)
                                                        .foregroundColor(.red)
                                                        .padding()
                                        }
                                        
                                        Button("Open Wallet") {
                                                validatePassword()
                                        }
                                        .padding()
                                        
                                        NavigationLink(destination: ImportWalletView().environmentObject(appState)) {
                                                Text("Forget Password")
                                                        .foregroundColor(.blue)
                                        }
                                        .padding()
                                }
                                .padding()
                                
                                // 显示加载提示
                                LoadingView(isVisible: $loadingManager.isVisible, message: $loadingManager.message)
                        }
                }
        }
        
        private func validatePassword() {
                errorMessage = nil
                loadingManager.show(message: "Decoding Wallet...") // 显示加载提示
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.openWallet(password: password)
                        
                        DispatchQueue.main.async {
                                loadingManager.hide() // 隐藏加载提示
                                if success {
                                        appState.isPasswordValidated = true
                                } else {
                                        errorMessage = "Invalid Password. Please try again."
                                }
                        }
                }
        }
}
