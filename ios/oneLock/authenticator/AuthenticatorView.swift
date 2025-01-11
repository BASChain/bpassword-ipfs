//
//  AuthenticatorView.swift
//  oneLock
//
//  Created by wesley on 2025/1/11.
//

import SwiftUI

struct AuthenticatorView: View {
        // 模拟的动态数据
        let accounts = [
                ("YouTube", "987 8473"),
                ("Google", "123 4567"),
                ("Facebook", "345 6789"),
                ("Twitter", "765 4321"),
                ("Instagram", "456 7890"),
                ("LinkedIn", "678 9012")
        ]
        
        var body: some View {
                NavigationView {
                        VStack {
                                ScrollView {
                                        VStack(spacing: 15) {
                                                // 动态生成卡片列表，修复 id 的问题
                                                ForEach(accounts, id: \.0) { account in
                                                        CodeCardView(serviceName: account.0, code: account.1)
                                                }
                                        }
                                        .padding()
                                }
                        }
                        .navigationBarTitle("Authenticator", displayMode: .inline)
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        HStack(spacing: 2) { // 修改按钮间距为 8pt
                                                
                                                Button(action: {
                                                        print("Add button tapped")
                                                }) {
                                                        Color.clear // 透明背景
                                                                .frame(width: 24, height: 24) // 设置Button的尺寸为24pt × 24pt
                                                                .overlay(
                                                                        Image("add_icon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 22, height: 22) // 设置Image的尺寸
                                                                )
                                                }
                                                Button(action: {
                                                        print("Scan button tapped")
                                                }) {
                                                        Color.clear // 使用透明背景
                                                                .frame(width: 24, height: 24) // 设置按钮的尺寸为 24pt
                                                                .overlay(
                                                                        Image("scan_icon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 22, height: 22) // 设置图标的尺寸
                                                                )
                                                } 
                                        }
                                }
                        }
                }
        }
}

struct CodeCardView: View {
        var serviceName: String
        var code: String
        @State private var remainingTime: Int = 30 // 倒计时剩余时间
        
        private let cardBackgroundColor = Color(red: 0.9, green: 0.95, blue: 0.95)
        private let circleStrokeColor = Color(red: 0.0, green: 0.7, blue: 0.8)
        
        var body: some View {
                HStack {
                        VStack(alignment: .leading, spacing: 8) {
                                // 服务名称
                                Text(serviceName)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                
                                // 验证码
                                Text(code)
                                        .font(.largeTitle)
                                        .foregroundColor(circleStrokeColor) // 浅蓝色
                                        .fontWeight(.bold)
                        }
                        Spacer()
                        // 倒计时图标
                        ZStack {
                                Circle()
                                        .stroke(circleStrokeColor, lineWidth: 4)
                                        .frame(width: 30, height: 30)
                                // 倒计时文本
                                Text("\(remainingTime)")
                                        .font(.caption)
                                        .foregroundColor(circleStrokeColor)
                        }
                }
                .padding()
                .background(cardBackgroundColor) // 浅蓝背景
                .cornerRadius(15) // 更大的圆角
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .onAppear {
                        startTimer()
                }
        }
        
        private func startTimer() {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        if remainingTime > 0 {
                                remainingTime -= 1
                        } else {
                                timer.invalidate()
                                remainingTime = 30 // 重置时间
                                // 在此添加验证码刷新逻辑（如果需要）
                        }
                }
        }
}
