//
//  BPassword_ipfsApp.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI
import SwiftData

@main
struct OneLockApp: App {
        
        @StateObject private var appState = AppState()
        
        init() {
                initializeSdk()
        }
        
        var body: some Scene {
                WindowGroup {
                        if appState.hasWallet {
                                if appState.isPasswordValidated {
                                        MainView().environmentObject(appState)
                                } else {
                                        PasswordView().environmentObject(appState) // 改为环境对象注入
                                                .onAppear { checkWalletStatus() }
                                }
                        } else {
                                WalletSetupView() .environmentObject(appState) // 改为环境对象注入
                                        .onAppear { checkWalletStatus() }
                        }
                }
        }
        
        private func initializeSdk() {
                print("Initializing SDK...")
                SdkUtil.shared.initializeSDK(logLevel: LogLevel.debug)
                print("SDK initialized.")
        }
        
        private func checkWalletStatus() {
                DispatchQueue.global().async {
                        if let walletData = SdkUtil.shared.checkWallet() {
                                DispatchQueue.main.async {
                                        appState.hasWallet = true
                                        appState.walletData = walletData
                                }
                        } else {
                                DispatchQueue.main.async {
                                        appState.hasWallet = false
                                }
                        }
                }
        }
}

class AppState: ObservableObject {
        @Published var hasWallet: Bool = false
        @Published var isPasswordValidated: Bool = false
        @Published var walletData: String? = nil
}
