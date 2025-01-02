//
//  BPassword_ipfsApp.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI

@main
struct OneLockApp: App {
        
        @StateObject private var appState = AppState()
        @StateObject private var toastManager = ToastManager() // 全局 Toast 管理器
        @Environment(\.scenePhase) private var scenePhase
        
        init() {
                initializeSdk()
        }
        
        
        var body: some Scene {
                
                WindowGroup {
                        ZStack {
                                // 根据 App 状态加载相应视图
                                if appState.hasWallet {
                                        if appState.isPasswordValidated {
                                                MainView()
                                                        .environmentObject(appState)
                                        } else {
                                                PasswordView()
                                                        .environmentObject(appState)
                                                        .onAppear { checkWalletStatus() }
                                        }
                                } else {
                                        WalletSetupView()
                                                .environmentObject(appState)
                                                .onAppear { checkWalletStatus() }
                                }
                        }
                        .toast(
                                isVisible: $toastManager.isVisible,
                                message: toastManager.message,
                                isSuccess: toastManager.isSuccess,
                                duration: toastManager.duration
                        )
                        .onAppear {
                                // 将 ToastManager 注入到 SdkUtil
                                SdkUtil.shared.toastManager = toastManager
                        }
                }
                .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                                print("++++++>>>App moved to the foreground.")
                                SdkUtil.shared.syncLocalData()
                        } else if newPhase == .background {
                                print("++++++>>>App moved to the background.")
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
        @Published var hasWallet: Bool = true
        @Published var isPasswordValidated: Bool = false
        @Published var walletData: String? = nil
}
