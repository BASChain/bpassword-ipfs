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
        @State private var isPasswordVisible: Bool = false
        
        
        var onSave: (() -> Void)? // 回调通知 HomeView 刷新
        
        var body: some View {
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
                                                isPasswordVisible.toggle()
                                        }) {
                                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                        .foregroundColor(.gray)
                                        }
                                }
                        }
                        Button("Save") {
                                saveAccount()
                        }
                }
                .navigationTitle("Add Account")
        }
        
        private func saveAccount() {
                let account = Account(platform: platform, username: username,
                                      password: password, lastUpdated: Int64(Date().timeIntervalSince1970))
                LoadingManager.shared.show(message: "Saving Account...")
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.addAccount(account: account)
                        
                        DispatchQueue.main.async {
                                LoadingManager.shared.hide()
                                if success {
                                        onSave?() // 通知 HomeView 刷新
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        print("Failed to save account")
                                        SdkUtil.shared.toastManager?.showToast(message: "Operation failed", isSuccess: false)
                                }
                        }
                }
        }
}
