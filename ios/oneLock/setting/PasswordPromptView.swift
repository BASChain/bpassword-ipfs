//
//  PasswordPromptView.swift
//  oneLock
//
//  Created by wesley on 2025/3/2.
//


import SwiftUI
struct PasswordPromptView: View {
        @Binding var isPresented: Bool
        var onPasswordSubmit: (String) -> Void
        @State private var password: String = ""
        
        var body: some View {
                if isPresented {
                        ZStack {
                                // 半透明背景遮罩
                                Color.black.opacity(0.4)
                                        .edgesIgnoringSafeArea(.all)
                                        .onTapGesture {
                                                isPresented = false
                                        }
                                
                                // 弹窗内容区域
                                VStack(spacing: 20) {
                                        // 标题，与 GenericAlertView 的标题样式一致
                                        Text("Enter Password")
                                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                                .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                                .multilineTextAlignment(.center)
                                        
                                        // 密码输入框（替代 GenericAlertView 的消息部分）
                                        SecureField("Password", text: $password)
                                                .font(.custom("HelveticaNeue", size: 14))
                                                .foregroundColor(Color(red: 103/255, green: 103/255, blue: 106/255))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                                .cornerRadius(8)
                                        
                                        // 按钮区域
                                        HStack(spacing: 16) {
                                                // 取消按钮，样式与 GenericAlertView 中的 Cancel 按钮一致
                                                Button(action: {
                                                        isPresented = false
                                                }) {
                                                        Text("Cancel")
                                                                .font(.custom("PingFangSC-Semibold", size: 16))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                                .padding(.vertical, 11)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                                                .cornerRadius(31)
                                                }
                                                
                                                // 确认按钮，样式与 GenericAlertView 中的 Confirm 按钮一致
                                                Button(action: {
                                                        onPasswordSubmit(password)
                                                        password = ""
                                                        isPresented = false
                                                }) {
                                                        Text("Confirm")
                                                                .font(.custom("PingFangSC-Semibold", size: 16))
                                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                                .padding(.vertical, 11)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color(red: 255/255, green: 161/255, blue: 54/255))
                                                                .cornerRadius(31)
                                                }
                                        }
                                        .padding(.horizontal, 16)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal, 40)
                        }
                }
        }
}
