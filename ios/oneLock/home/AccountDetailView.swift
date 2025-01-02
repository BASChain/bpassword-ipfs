//
//  AccountDetailView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//

import SwiftUI

struct AccountDetailView: View {
        @Binding var account: Account // 使用 @Binding 从父视图传递进来
        @State private var isPasswordVisible: Bool = false
        @State private var showAlert: Bool = false
        @State private var showLoading: Bool = false
        @State private var showEditView: Bool = false // 控制跳转到编辑界面
        @Environment(\.presentationMode) var presentationMode
        var onAccountDeleted: (() -> Void)?
        
        var body: some View {
                ZStack {
                        VStack(spacing: 20) {
                                Text("Platform: \(account.platform)")
                                        .font(.title)
                                Text("Username: \(account.username)")
                                        .font(.headline)
                                ZStack {
                                        Text(account.password)
                                                .font(.headline)
                                                .foregroundColor(.red)
                                                .opacity(isPasswordVisible ? 1.0 : 0.0)
                                        
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
                                
                                Button(action: {
                                        showAlert = true
                                }) {
                                        Text("Delete Account")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.red)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                }
                                
                                Button(action: {
                                        showEditView = true // 跳转到编辑界面
                                }) {
                                        Text("Edit Account")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                }
                                
                                Spacer()
                        }
                        .padding()
                        .navigationTitle("Account Details")
                        
                        GenericAlertView(
                                isPresented: $showAlert,
                                title: "Confirm Deletion",
                                message: "Are you sure you want to delete this account?",
                                onConfirm: deleteAccount,
                                onCancel: {
                                        showAlert = false
                                }
                        )
                        
                        if showLoading {
                                LoadingView(isVisible: $showLoading, message: .constant("Deleting Account..."))
                        }
                }
                .sheet(isPresented: $showEditView) {
                        EditAccountView(account: account) { updatedAccount in
                                // 更新当前界面显示的 Account 数据
                                account = updatedAccount
                                print("Updated account:", updatedAccount)
                        }
                }
        }
        
        private func deleteAccount() {
                showAlert = false
                showLoading = true
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.removeAccount(uuid: account.id)
                        
                        DispatchQueue.main.async {
                                showLoading = false
                                if success {
                                        onAccountDeleted?()
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        print("Failed to delete account")
                                }
                        }
                }
        }
}
