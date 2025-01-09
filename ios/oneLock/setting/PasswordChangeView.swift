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
                        
                        // 输入旧密码
                        HStack {
                                if showOldPassword {
                                        TextField("Enter Old Password", text: $oldPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                } else {
                                        SecureField("Enter Old Password", text: $oldPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                }
                                Button(action: {
                                        showOldPassword.toggle()
                                }) {
                                        Image(showOldPassword ?  "opened-gray-icon": "closed-icon") // 替换为设计图中的实际图片
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
                                }
                        }
                        .padding(.horizontal)
                        
                        // 输入新密码
                        HStack {
                                if showNewPassword {
                                        TextField("Enter New Password", text: $newPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                } else {
                                        SecureField("Enter New Password", text: $newPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                }
                                Button(action: {
                                        showNewPassword.toggle()
                                }) {
                                        Image(showNewPassword ? "opened-gray-icon"  : "closed-icon") // 替换为设计图中的实际图片
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
                                }
                        }
                        .padding(.horizontal)
                        
                        // 确认新密码
                        HStack {
                                if showConfirmPassword {
                                        TextField("Confirm New Password", text: $confirmPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                } else {
                                        SecureField("Confirm New Password", text: $confirmPassword)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding()
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                }
                                Button(action: {
                                        showConfirmPassword.toggle()
                                }) {
                                        Image(showConfirmPassword ? "opened-gray-icon":  "closed-icon" ) // 替换为设计图中的实际图片
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
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
                                        .font(.custom("Helvetica-Bold", size: 16))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                        .cornerRadius(31)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .toolbar {
                        ToolbarItem(placement: .principal) {
                                Text("Change Password")
                                        .font(.custom("SFProText-Medium", size: 18))
                                        .foregroundColor(Color.black)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                }) {
                                        Image("back_icon") // 替换为实际的返回图标
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                }
                        }
                }
        }
        
        private func validateAndSubmit() {
                // 验证输入
                guard !oldPassword.isEmpty else {
                        errorMessage = "Old password cannot be empty."
                        return
                }
                // 验证输入
                guard !newPassword.isEmpty, newPassword.count >= 8 else {
                        errorMessage = newPassword.isEmpty ? "New password cannot be empty." : "New password must be at least 8 characters long."
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
