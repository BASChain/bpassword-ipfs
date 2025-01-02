//
//  PasswordChangeView.swift
//  oneLock
//
//  Created by wesley on 2025/1/2.
//

import SwiftUI

struct PasswordChangeView: View {
        @Environment(\.presentationMode) var presentationMode
        
        @State private var oldPassword: String = ""
        @State private var newPassword: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var showOldPassword: Bool = false
        @State private var showNewPassword: Bool = false
        @State private var showConfirmPassword: Bool = false
        
        var body: some View {
                VStack(spacing: 20) {
                        Text("Change Password")
                                .font(.headline)
                                .padding()
                        
                        // 输入旧密码
                        HStack {
                                if showOldPassword {
                                        TextField("Enter Old Password", text: $oldPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                        SecureField("Enter Old Password", text: $oldPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                Button(action: {
                                        showOldPassword.toggle()
                                }) {
                                        Image(systemName: showOldPassword ? "eye.slash" : "eye")
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.horizontal)
                        
                        // 输入新密码
                        HStack {
                                if showNewPassword {
                                        TextField("Enter New Password", text: $newPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                        SecureField("Enter New Password", text: $newPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                Button(action: {
                                        showNewPassword.toggle()
                                }) {
                                        Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.horizontal)
                        
                        // 确认新密码
                        HStack {
                                if showConfirmPassword {
                                        TextField("Confirm New Password", text: $confirmPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                        SecureField("Confirm New Password", text: $confirmPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                Button(action: {
                                        showConfirmPassword.toggle()
                                }) {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.horizontal)
                        
                        // 错误信息
                        if let errorMessage = errorMessage {
                                Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                        }
                        
                        // 提交按钮
                        Button(action: validateAndSubmit) {
                                Text("Submit")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                }
                .padding()
        }
        
        private func validateAndSubmit() {
                // 验证输入
                guard !oldPassword.isEmpty else {
                        errorMessage = "Old password cannot be empty."
                        return
                }
                guard !newPassword.isEmpty else {
                        errorMessage = "New password cannot be empty."
                        return
                }
                guard newPassword == confirmPassword else {
                        errorMessage = "New passwords do not match."
                        return
                }
                guard oldPassword != newPassword else {
                        errorMessage = "New password cannot be the same as the old password."
                        return
                }
                
                errorMessage = nil
                LoadingManager.shared.show(message: "Changing Password...")
                
                DispatchQueue.global().async {
                        let errorStr = SdkUtil.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                        DispatchQueue.main.async {
                                LoadingManager.shared.hide() // 隐藏加载提示
                                if errorStr == nil {
                                        SdkUtil.shared.toastManager?.showToast(message: "Operation Success", isSuccess: true)
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        errorMessage = errorStr
                                }
                        }
                }
        }
}
