//
//  AddAccountView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//
import SwiftUI

struct AddAccountView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var platform: String = ""
        @State private var username: String = ""
        @State private var password: String = ""
        @State private var isPasswordVisible: Bool = false // 控制密码可见性
        @StateObject private var loadingManager = LoadingManager() // 添加 LoadingManager
        
        var body: some View {
                ZStack {
                        Form {
                                Section(header: Text("Platform")) {
                                        TextField("Enter platform name", text: $platform)
                                }
                                Section(header: Text("Username")) {
                                        TextField("Enter username", text: $username)
                                }
                                Section(header: Text("Password")) {
                                        HStack {
                                                if isPasswordVisible {
                                                        TextField("Enter password", text: $password)
                                                                .textFieldStyle(.roundedBorder)
                                                } else {
                                                        SecureField("Enter password", text: $password)
                                                                .textFieldStyle(.roundedBorder)
                                                }
                                                Button(action: {
                                                        isPasswordVisible.toggle() // 切换密码可见性
                                                }) {
                                                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                                .foregroundColor(.gray)
                                                }
                                        }
                                }
                                Button("Save") {
                                        saveAccount() // 调用保存逻辑
                                }
                        }
                        .navigationTitle("Add Account")
                        
                        // 显示加载提示
                        LoadingView(isVisible: $loadingManager.isVisible, message: $loadingManager.message)
                }
        }
        
        private func saveAccount() {
                let account = Account(platform: platform, username: username,
                                      password: password, lastUpdated: Int64(Date().timeIntervalSince1970))
                loadingManager.show(message: "Saving Account...") // 显示加载提示
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.addAccount(account: account)
                        
                        DispatchQueue.main.async {
                                loadingManager.hide() // 隐藏加载提示
                                if success {
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        print("Failed to save account")
                                }
                        }
                }
        }
}
