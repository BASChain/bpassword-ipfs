import SwiftUI

struct AuthenticatorView: View {
        
        @State private var hasLoaded = false // 防止重复加载
        @StateObject private var authManager = AuthManager()
        var body: some View {
                NavigationView {
                        VStack {
                                List {
                                        ForEach(authManager.accounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, account in
                                                
                                                CodeCardView(authAccount: account)
                                                        .swipeActions {
                                                                Button(role: .destructive) {
                                                                        // 删除逻辑，这里可以调用删除操作
                                                                        removeByKey(key:key)
                                                                } label: {
                                                                        Label("Delete", systemImage: "trash")
                                                                }
                                                                .tint(Color(red: 255/255, green: 161/255, blue: 54/255)) // 设置颜色为 rgba(255, 161, 54, 1)
                                                        }
                                                        .padding(.vertical, 10) // 保持原有的间距
                                        }
                                        .listRowInsets(EdgeInsets()) // 去除默认的内边距
                                        .listRowSeparator(.hidden) // 隐藏分隔线
                                }
                                .padding(.top, 15) // 保持原来的顶部间距
                                .listStyle(PlainListStyle()) // 使用简单的列表样式
                        }
                        .navigationBarTitle("Authenticator", displayMode: .inline)
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        HStack(spacing: 2) {
                                                NavigationLink(destination: NewAuthAccountView(onSave: authManager.reloadAccounts)) {
                                                        Color.clear
                                                                .frame(width: 24, height: 24)
                                                                .overlay(
                                                                        Image("add_icon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 22, height: 22)
                                                                )
                                                }
                                                NavigationLink(destination: AuthScanView(onScanComplete: procScanedCode)) {
                                                        Color.clear
                                                                .frame(width: 24, height: 24)
                                                                .overlay(
                                                                        Image("scan_icon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 22, height: 22)
                                                                )
                                                }
                                        }
                                }
                        }
                }
                .onAppear {
                        authManager.reloadAccounts()
                }
        }
        
        private func removeByKey(key:String){
                LoadingManager.shared.show(message: "processing scanned code......")
                
                DispatchQueue.global().async {
                        do {
                                try SdkUtil.shared.DelAuth(key: key)
                                LoadingManager.shared.hide()
                                authManager.reloadAccounts()
                                
                        } catch {
                                LoadingManager.shared.hide()
                                print("Error saving account: \(error.localizedDescription)")
                                SdkUtil.shared.toastManager?.showToast(message: "An error occurred: \(error.localizedDescription)", isSuccess: false)
                                
                        }
                }
        }
        
        private func procScanedCode(scannedCode:String?){
                guard let code = scannedCode else{
                        return
                }
                LoadingManager.shared.show(message: "processing scanned code......")
                DispatchQueue.global().async {
                        do {
                                try SdkUtil.shared.NewAuthScanned(code: code)
                                authManager.reloadAccounts()
                                LoadingManager.shared.hide()
                                
                        } catch {
                                LoadingManager.shared.hide()
                                print("Error saving account: \(error.localizedDescription)")
                                SdkUtil.shared.toastManager?.showToast(message: "An error occurred: \(error.localizedDescription)", isSuccess: false)
                        }
                }
        }
}

struct CodeCardView: View {
        let authAccount: AuthAccount
        
        private let cardBackgroundColor = Color(red: 243/255, green: 249/255, blue: 250/255) // 修改背景颜色为 rgba(243, 249, 250, 1)
        private let circleStrokeColor = Color(red: 0.0, green: 0.7, blue: 0.8)
        private let warningColor = Color(red: 255/255, green: 161/255, blue: 54/255)
        
        var body: some View {
                HStack {
                        VStack(alignment: .leading, spacing: 8) {
                                // 服务名称
                                Text(authAccount.id)
                                        .font(.system(size: 14, weight: .medium)) // 使用系统字体替代 SF Pro Text Medium, 大小为 14pt
                                        .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255)) // 修改颜色为 rgba(25, 25, 29, 1)
                                
                                // 验证码
                                Text(authAccount.code)
                                        .font(.system(size: 24, weight: .medium)) // 替换为系统字体，与 Helvetica Neue Medium 接近，大小为 24pt
                                        .foregroundColor(Color(red: 23/255, green: 212/255, blue: 213/255)) // 修改颜色为 rgba(23, 212, 213, 1)
                                        .fontWeight(.bold)
                        }
                        .padding(.leading, 20) // 设置左侧距离为 20pt
                        Spacer()
                        // 倒计时图标
                        ZStack {
                                Circle()
                                        .stroke(
                                                authAccount.timeLeft <= 10 ? warningColor : circleStrokeColor,
                                                lineWidth: 4
                                        )
                                        .frame(width: 30, height: 30)
                                // 倒计时文本
                                Text("\(authAccount.timeLeft)")
                                        .font(.caption)
                                        .foregroundColor(
                                                authAccount.timeLeft <= 10 ? warningColor : circleStrokeColor
                                        )
                        }
                }
                .padding()
                .background(cardBackgroundColor) // 浅蓝背景
                .cornerRadius(13) // 更大的圆角
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .onTapGesture {
                        UIPasteboard.general.string = authAccount.code // 复制code到剪贴板
                        SdkUtil.shared.toastManager?.showToast(message: "Copy Success", isSuccess: true, duration: 1.0)
                }
        }
}
