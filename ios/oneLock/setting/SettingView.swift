//
//  SettingView.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//
import SwiftUI

struct SettingView: View {
        @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
        @State private var showPasswordChangeView = false // 控制密码修改视图的显示
        let blockchainAddress: String = SdkUtil.shared.walletAddress()
        
        var body: some View {
                NavigationView {
                        VStack(spacing: 20) {
                                // 第一部分：显示用户的区块链地址
                                VStack(alignment: .leading, spacing: 10) {
                                        Text("Your Blockchain Address")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        Text(blockchainAddress)
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .lineLimit(1)
                                                .truncationMode(.middle) // 截断长地址中间部分
                                                .padding()
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(10)
                                                .contextMenu {
                                                        Button(action: {
                                                                UIPasteboard.general.string = blockchainAddress
                                                        }) {
                                                                Label("Copy Address", systemImage: "doc.on.doc")
                                                        }
                                                }
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                                
                                // 第二部分：设置列表
                                List {
                                        // 自动关闭钱包时长设置
                                        Section(header: Text("Wallet Settings")) {
                                                HStack {
                                                        Text("Auto Close Wallet Duration")
                                                        Spacer()
                                                        Picker("", selection: $autoCloseDuration) {
                                                                ForEach([1, 5, 10, 15, 30, 60], id: \.self) { value in
                                                                        Text("\(value) min").tag(value)
                                                                }
                                                        }
                                                        .pickerStyle(MenuPickerStyle())
                                                        .onChange(of: autoCloseDuration) { newValue in
                                                                let success = SdkUtil.shared.setAutoCloseDuration(newValue) // 保存用户选择的值
                                                                if !success{
                                                                        SdkUtil.shared.toastManager?.showToast(message: "Save Failed!", isSuccess: false)
                                                                }else{
                                                                        SdkUtil.shared.toastManager?.showToast(message: "Save Success!", isSuccess: true)
                                                                }
                                                        }
                                                }
                                        }
                                        
                                        // 修改密码
                                        Section {
                                                // 修改密码
                                                NavigationLink(destination: PasswordChangeView()) {
                                                        HStack {
                                                                Text("Change Password")
                                                                Spacer()
                                                                Image(systemName: "lock")
                                                                        .foregroundColor(.gray)
                                                        }
                                                }
                                        }
                                        
                                        // 当前版本号
                                        Section(header: Text("App Info")) {
                                                HStack {
                                                        Text("Current Version")
                                                        Spacer()
                                                        Text(SdkUtil.shared.getVersion())
                                                                .foregroundColor(.gray)
                                                }
                                        }
                                        
                                        // 分享本 APP
                                        Section {
                                                Button(action: {
                                                        shareApp()
                                                }) {
                                                        HStack {
                                                                Text("Share This App")
                                                                Spacer()
                                                                Image(systemName: "square.and.arrow.up")
                                                                        .foregroundColor(.blue)
                                                        }
                                                }
                                        }
                                }
                                .listStyle(InsetGroupedListStyle())
                        }
                        .navigationTitle("Settings")
                }
        }
        
        /// 分享 App 的逻辑
        private func shareApp() {
                
                guard let url = URL(string: SdkUtil.AppUrl) else { return }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                // 使用适配 iOS 15 及以上的逻辑
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(activityVC, animated: true, completion: nil)
                } else {
                        print("Unable to present activity view controller")
                }
        }
}
