//
//  WalletSetupView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI

struct WalletSetupView: View {
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                NavigationView {
                        ZStack {
                                // 设置深蓝色背景
                                Color(red: 20/255, green: 36/255, blue: 54/255)
                                        .edgesIgnoringSafeArea(.all)
                                
                                GeometryReader { geometry in
                                        VStack {
                                                // 显示 Logo 和应用名称
                                                VStack {
                                                        Image("logo") // 替换为您的 Logo 图片名称
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: 74, height: 74)
                                                        
                                                        Text("BPassword")
                                                                .font(Font.custom("SF Pro Text", size: 26).weight(.bold))
                                                                .foregroundColor(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .padding(.top, 11)
                                                }
                                                .id("logo area")
                                                .padding(.top, geometry.size.height * 0.18) // 动态调整 Logo 到顶部的间距
                                                
                                                Spacer()
                                                
                                                // 按钮区域
                                                VStack(spacing: geometry.size.height * 0.02) { // 动态调整按钮之间的间距
                                                        // 创建钱包按钮
                                                        NavigationLink(destination: CreateWalletView().environmentObject(appState)) {
                                                                Text("Create Wallet")
                                                                        .font(.system(size: 16, weight: .semibold))
                                                                        .foregroundColor(.white)
                                                                        .padding()
                                                                        .frame(maxWidth: .infinity)
                                                                        .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                                        .cornerRadius(31) // 设置按钮圆角
                                                        }
                                                        .padding(.horizontal, 48)
                                                        
                                                        // 导入钱包按钮
                                                        NavigationLink(destination: ImportWalletView().environmentObject(appState)) {
                                                                Text("Import Wallet")
                                                                        .font(.system(size: 16, weight: .semibold))
                                                                        .foregroundColor(Color(red: 4/255, green: 23/255, blue: 39/255))
                                                                        .padding()
                                                                        .frame(maxWidth: .infinity)
                                                                        .background(Color(red: 255/255, green: 161/255, blue: 54/255))
                                                                        .cornerRadius(31) // 设置按钮圆角
                                                                        .overlay(
                                                                                RoundedRectangle(cornerRadius: 31)
                                                                                        .stroke(Color(red: 255/255, green: 161/255, blue: 54/255), lineWidth: 2) // 设置按钮边框
                                                                        )
                                                        }
                                                        .padding(.horizontal, 48)
                                                }
                                                .padding(.bottom, geometry.size.height * 0.20) // 增加按钮区域到底部的间距以向上移动
                                        }
                                        .navigationTitle("Wallet Setup") // 设置导航标题
                                        .navigationBarHidden(true) // 隐藏导航栏
                                }
                        }
                }
        }
}
