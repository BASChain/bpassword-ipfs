import SwiftUI

struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var mnemonic: String? = nil
        @EnvironmentObject var appState: AppState  // 环境对象引用
        
        var body: some View {
                // 如果已经生成了助记词，就跳转到 MnemonicView
                if let mnemonicPhrase = mnemonic {
                        MnemonicView(mnemonic: mnemonicPhrase, password: password)
                                .environmentObject(appState)
                } else {
                        GeometryReader { geometry in
                                VStack(spacing: 0) {
                                        // Section 1：上方背景图片 + 标题
                                        ZStack(alignment: .topLeading) {
                                                Image("password-img")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: geometry.size.width, height: 215)
                                                        .clipped()
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                        Text("Create\nAccount")
                                                                .font(.system(size: 28, weight: .bold))
                                                                .foregroundColor(Color(red: 20 / 255,
                                                                                       green: 36 / 255,
                                                                                       blue: 54 / 255))
                                                                .lineSpacing(6)
                                                }
                                                .padding(.top, 14)
                                                .padding(.leading, 21)
                                        }
                                        .frame(height: 215)
                                        
                                        // Section 2：白色圆角背景 + 输入框 + 按钮
                                        ZStack {
                                                RoundedRectangle(cornerRadius: 31)
                                                        .fill(Color.white)
                                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: -2)
                                                
                                                VStack(spacing: 24) {
                                                        // 输入框 1
                                                        SecureField("Enter Password", text: $password)
                                                                .padding(.horizontal, 16)
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(24)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255))
                                                        
                                                        // 输入框 2
                                                        SecureField("Confirm Password", text: $confirmPassword)
                                                                .padding(.horizontal, 16)
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(24)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255))
                                                        
                                                        // 错误提示
                                                        if let error = errorMessage {
                                                                Text(error)
                                                                        .foregroundColor(.red)
                                                                        .multilineTextAlignment(.center)
                                                                        .padding(.horizontal, 10)
                                                        }
                                                        
                                                        // 生成钱包按钮
                                                        Button(action: {
                                                                generateWallet()
                                                        }) {
                                                                RoundedRectangle(cornerRadius: 31)
                                                                        .fill(Color(red: 15 / 255, green: 211 / 255, blue: 212 / 255))
                                                                        .frame(height: 50)
                                                                        .overlay(
                                                                                Text("Generate Wallet")
                                                                                        .font(.system(size: 16, weight: .semibold))
                                                                                        .foregroundColor(.white)
                                                                        )
                                                        }
                                                }
                                                .padding(24)
                                        }
                                        // 剩余的可用高度都给 Section 2
                                        .frame(height: geometry.size.height - 215)
                                }
                                // 可选：让背景图片延伸到安全区域之外
                                .ignoresSafeArea()
                                // 点击空白处收起键盘
                                .onTapGesture {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                        to: nil, from: nil, for: nil)
                                }
                        }
                }
        }
        
        private func generateWallet() {
                // 检查密码是否一致
                guard password == confirmPassword else {
                        errorMessage = "Passwords do not match"
                        return
                }
                
                // 调用 SDK 工具生成助记词
                if let generatedMnemonic = SdkUtil.shared.generateMnemonic() {
                        mnemonic = generatedMnemonic
                        errorMessage = nil
                } else {
                        errorMessage = "Failed to generate wallet. Please try again."
                }
        }
}
