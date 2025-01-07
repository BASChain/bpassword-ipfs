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
                                Color(red: 20/255, green: 36/255, blue: 54/255) // 背景颜色
                                        .edgesIgnoringSafeArea(.all)
                                
                                VStack {
                                        
                                        // Logo 和 BPassword 文字
                                        VStack {
                                                Image("logo") // 替换为您的 Logo 图片名称
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 74, height: 74)
                                                
                                                Text("BPassword")
                                                        .font(.system(size: 26, weight: .bold))
                                                        .foregroundColor(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                        .padding(.top, 11)
                                        }.id("logo area")
                                                .padding(.top, 120)
                                        
                                        // 创建钱包按钮
                                        NavigationLink(destination: CreateWalletView().environmentObject(appState)) {
                                                Text("Create Wallet")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                        .cornerRadius(31) // 按钮圆角
                                        }
                                        .padding(.horizontal, 48)
                                        .padding(.top, 214)
                                        
                                        // 导入钱包按钮
                                        NavigationLink(destination: ImportWalletView().environmentObject(appState)) {
                                                Text("Import Wallet")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(Color(red: 4/255, green: 23/255, blue: 39/255))
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color(red: 255/255, green: 161/255, blue: 54/255))
                                                        .cornerRadius(31) // 按钮圆角
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 31)
                                                                        .stroke(Color(red: 255/255, green: 161/255, blue: 54/255), lineWidth: 2)
                                                        )
                                        }
                                        .padding(.horizontal, 48)
                                        .padding(.top, 18)
                                        
                                        Spacer()
                                }
                                .navigationTitle("Wallet Setup")
                                .navigationBarHidden(true)
                        }
                }
        }
}
