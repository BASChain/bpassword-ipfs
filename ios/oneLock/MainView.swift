//
//  ContentView.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI

struct MainView: View {
        @StateObject private var toastManager = ToastManager() // 全局 Toast 管理器
        var body: some View {
                TabView {
                        HomeView()
                                .tabItem {
                                        Label("Home", systemImage: "house")
                                }
                        
                        SettingView()
                                .tabItem {
                                        Label("Setting", systemImage: "gearshape")
                                }
                }
                .toast(isVisible: $toastManager.isVisible, message: toastManager.message, isSuccess: toastManager.isSuccess, duration: toastManager.duration)
                .environmentObject(toastManager) // 注入到环境中，子视图可访问
                .onAppear {
                    // 将 ToastManager 注入到 SdkUtil
                    SdkUtil.shared.toastManager = toastManager
                }
        }
}
