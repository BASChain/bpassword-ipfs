import SwiftUI

struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var mnemonic: String? = nil
        @EnvironmentObject var appState: AppState // 添加环境对象引用
        @Environment(\.dismiss) private var dismiss // 用于返回上一页面
        
        var body: some View {
                if let mnemonicPhrase = mnemonic {
                        // 显示 MnemonicView
                        MnemonicView(mnemonic: mnemonicPhrase, password: password)
                                .environmentObject(appState)
                } else {
                        // 显示创建钱包视图
                        ZStack {
                                // 背景
                                Color.white
                                        .edgesIgnoringSafeArea(.all)
                                
                                VStack(spacing: 0) {
                                        // Section 1
                                        ZStack(alignment: .topLeading) {
                                                // 背景图片
                                                Image("password-img")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: UIScreen.main.bounds.width, height: 262)
                                                        .clipped().ignoresSafeArea(edges: .top)
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                        // 标题
                                                        Text("Create\nAccount")
                                                                .font(.system(size: 28, weight: .bold))
                                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                                .lineSpacing(6)
                                                }
                                                .padding(.top, 14)
                                                .padding(.leading, 21)
                                        }
                                        
                                        Spacer() // 为了占据剩余的空间
                                }
                                
                                // Section 2 (覆盖部分)
                                ZStack {
                                        // 背景颜色和圆角
                                        RoundedRectangle(cornerRadius: 31)
                                                .fill(Color.white)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: -2)
                                        
                                        VStack() { // 调整间距
                                                // 输入框 1
                                                SecureField("Enter Password", text: $password)
                                                        .padding(.horizontal, 16) // 内边距
                                                        .frame(height: 50) // 高度
                                                        .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255)) // 背景颜色
                                                        .cornerRadius(24) // 圆角
                                                        .font(.system(size: 16)) // 字体
                                                        .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255)) // 字体颜色
                                                
                                                // 输入框 2
                                                SecureField("Confirm Password", text: $confirmPassword)
                                                        .padding(.horizontal, 16)
                                                        .frame(height: 50)
                                                        .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                        .cornerRadius(24)
                                                        .font(.system(size: 16))
                                                        .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255))
                                                
                                                if let error = errorMessage {
                                                        Text(error)
                                                                .foregroundColor(.red)
                                                                .padding()
                                                }
                                                
                                                // 按钮
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
                                        } .padding(.top, 32) // 调整顶部间距
                                }
                                .frame(height: 700)
                                .offset(y: 85) // 调整 Section 2 向上覆盖 Section 1 的底部
                        }
                        .contentShape(Rectangle()) // 确保手势覆盖整个区域
                        .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .navigationBarBackButtonHidden(true) // 隐藏系统返回按钮
                        .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                                dismiss() // 自定义返回逻辑
                                        }) {
                                                Image("back_icon") // 使用自定义的图片
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, height: 24) // 调整图片大小
                                        }
                                }
                        }
                }
        }
        
        private func generateWallet() {
                guard password == confirmPassword else {
                        errorMessage = "Passwords do not match"
                        return
                }
                
                // 调用 SdkUtil 来生成助记词
                if let generatedMnemonic = SdkUtil.shared.generateMnemonic() {
                        mnemonic = generatedMnemonic
                        errorMessage = nil
                } else {
                        errorMessage = "Failed to generate wallet. Please try again."
                }
        }
}
