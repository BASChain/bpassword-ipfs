//
//  EditAccountView.swift
//  oneLock
//
//  Created by wesley on 2025/1/2.
//

import SwiftUI

struct EditAccountView: View {
        @State private var account: Account // 本地 Account 对象
        @State private var isPasswordVisible: Bool = false
        var onUpdate: (Account) -> Void // 更新回调
        @Environment(\.presentationMode) var presentationMode // 控制视图返回
        
        init(account: Account, onUpdate: @escaping (Account) -> Void) {
                self._account = State(initialValue: account) // 直接将 account 赋值为本地状态
                self.onUpdate = onUpdate
        }
        
        var body: some View {
                NavigationView {
                        VStack(spacing: 20) {
                                TextField("Platform", text: $account.platform)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Username", text: $account.username)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                HStack {
                                        if isPasswordVisible {
                                                TextField("Password", text: $account.password)
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        } else {
                                                SecureField("Password", text: $account.password)
                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        Button(action: {
                                                isPasswordVisible.toggle()
                                        }) {
                                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                                        .foregroundColor(.gray)
                                        }
                                }
                                
                                Button(action: updateAccount) {
                                        Text("Update")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                }
                                
                                Spacer()
                        }
                        .padding()
                        .navigationTitle("Edit Account")
                        .navigationBarItems(leading: Button("Cancel") {
                                presentationMode.wrappedValue.dismiss() // 返回上一视图
                        })
                }
        }
        
        private func updateAccount() {
                
                account.lastUpdated = Int64(Date().timeIntervalSince1970)
                LoadingManager.shared.show(message: "Updating Account...")
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.addAccount(account: self.account)
                        DispatchQueue.main.async {
                                LoadingManager.shared.hide()
                                if success {
                                        onUpdate(account)
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        print("Failed to save account")
                                        SdkUtil.shared.toastManager?.showToast(message: "Operation failed", isSuccess: false)
                                }
                        }
                }
        }
}
