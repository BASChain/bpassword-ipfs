//
//  BPassword_ipfsApp.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI

class AppStateManager {
        static let shared = AppStateManager()
        var appState = AppState() // 这里是全局的 AppState
        
        private init() {}
}


@main
struct OneLockApp: App {
        private var appState = AppState()
        @StateObject private var toastManager = ToastManager()
        init(){
                SdkUtil.shared.initializeSDK(logLevel: LogLevel.debug)
                AppStateManager.shared.appState.hasWallet = SdkUtil.shared.initWalletStatus()
                requestNetworkPermissionAndInitialize()
        }
        
        var body: some Scene {
                WindowGroup {
                        RootView()
                                .environmentObject(AppStateManager.shared.appState) // 注入全局的 AppState
                                .toast(
                                        isVisible: $toastManager.isVisible,
                                        message: toastManager.message,
                                        isSuccess: toastManager.isSuccess,
                                        duration: toastManager.duration
                                )
                                .loadingView()
                                .onAppear {
                                        SdkUtil.shared.toastManager = toastManager
                                }
                }
        }
        
        /// 初始化流程：申请网络权限并初始化 SDK
        private func requestNetworkPermissionAndInitialize() {
                NetworkPermissionManager.shared.requestPermission { granted in
                        if granted {
                                print("Network permission granted.")
                                
                        } else {
                                print("Network permission denied.")
                                handlePermissionDenied()
                        }
                }
        }
        
        
        
        /// 处理权限被拒绝的情况
        private func handlePermissionDenied() {
                DispatchQueue.main.async {
                        print("Permission denied. Some features may not work.")
                }
        }
}

class AppState: ObservableObject {
        @Published var hasWallet: Bool = false
        @Published var isPasswordValidated: Bool = false
}

struct RootView: View {
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                Group {
                        if appState.hasWallet {
                                if appState.isPasswordValidated {
                                        MainView()
                                } else {
                                        PasswordView()
                                }
                        } else {
                                WalletSetupView()
                        }
                }
        }
}
