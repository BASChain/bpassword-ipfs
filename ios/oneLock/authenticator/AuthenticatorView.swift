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
                                List {
                                        ForEach(accounts, id: \.0) { account in
                                                CodeCardView(serviceName: account.0, code: account.1)
                                                        .swipeActions {
                                                                Button(role: .destructive) {
                                                                        // 删除逻辑，这里可以调用删除操作
                                                                        print("\(account.0) deleted")
                                                                } label: {
                                                                        Label("Delete", systemImage: "trash")
                                                                }
                                                        }
                                                        .padding(.vertical, 10) // 保持原有的间距
                                        }
                                        .listRowInsets(EdgeInsets()) // 去除默认的内边距
                                }
                                .padding(.top, 15) // 保持原来的顶部间距
                                .listStyle(PlainListStyle()) // 移除分隔符和默认样式
                        }
                        .navigationBarTitle("Authenticator", displayMode: .inline)
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        HStack(spacing: 2) { // 修改按钮间距为 8pt
                                                NavigationLink(destination: NewAuthAccountView()) {
                                                        Color.clear // 透明背景
                                                                .frame(width: 24, height: 24) // 设置Button的尺寸为24pt × 24pt
                                                                .overlay(
                                                                        Image("add_icon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 22, height: 22) // 设置Image的尺寸
                                                                )
                                                }
                                                NavigationLink(destination: AuthScanView()) {
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
        
        private let cardBackgroundColor = Color(red: 243/255, green: 249/255, blue: 250/255) // 修改背景颜色为 rgba(243, 249, 250, 1)
        private let circleStrokeColor = Color(red: 0.0, green: 0.7, blue: 0.8)
        
        var body: some View {
                HStack {
                        VStack(alignment: .leading, spacing: 8) {
                                // 服务名称
                                Text(serviceName)
                                        .font(.system(size: 14, weight: .medium)) // 使用系统字体替代 SF Pro Text Medium, 大小为 14pt
                                        .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255)) // 修改颜色为 rgba(25, 25, 29, 1)
                                
                                // 验证码
                                Text(code)
                                        .font(.system(size: 24, weight: .medium)) // 替换为系统字体，与 Helvetica Neue Medium 接近，大小为 24pt
                                        .foregroundColor(Color(red: 23/255, green: 212/255, blue: 213/255)) // 修改颜色为 rgba(23, 212, 213, 1)
                                        .fontWeight(.bold)
                        }
                        .padding(.leading, 20) // 设置左侧距离为 20pt
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
                .cornerRadius(13) // 更大的圆角
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .onTapGesture {
                        UIPasteboard.general.string = code // 复制code到剪贴板
                        SdkUtil.shared.toastManager?.showToast(message: "Copy Success", isSuccess: true, duration: 1.0)
                }
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
