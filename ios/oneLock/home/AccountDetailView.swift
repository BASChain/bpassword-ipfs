//
//  AccountDetailView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//
import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false // 控制 GenericAlertView 的显示
    @State private var showLoading: Bool = false // 控制 LoadingView 的显示
    @Environment(\.presentationMode) var presentationMode
    var onAccountDeleted: (() -> Void)? // 回调通知 HomeView 刷新

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
                        .opacity(isPasswordVisible ? 1.0 : 0.0) // 密码默认隐藏

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
                    showAlert = true // 显示删除确认弹框
                }) {
                    Text("Delete Account")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Account Details")

            // GenericAlertView 用于确认删除
            GenericAlertView(
                isPresented: $showAlert,
                title: "Confirm Deletion",
                message: "Are you sure you want to delete this account?",
                onConfirm: deleteAccount,
                onCancel: {
                    showAlert = false // 隐藏弹框
                }
            )

            // LoadingView 用于显示删除进度
            if showLoading {
                LoadingView(isVisible: $showLoading, message: .constant("Deleting Account..."))
            }
        }
    }

    private func deleteAccount() {
        showAlert = false // 隐藏弹框
        showLoading = true // 显示加载提示

        DispatchQueue.global().async {
            let success = SdkUtil.shared.removeAccount(uuid: account.id)

            DispatchQueue.main.async {
                showLoading = false // 隐藏加载提示
                if success {
                    onAccountDeleted?() // 通知 HomeView 刷新
                    presentationMode.wrappedValue.dismiss() // 返回 HomeView
                } else {
                    print("Failed to delete account")
                }
            }
        }
    }
}
