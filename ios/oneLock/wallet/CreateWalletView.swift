import SwiftUI

struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var mnemonic: String? = nil
        @EnvironmentObject var appState: AppState // 添加环境对象引用
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
                if let mnemonicPhrase = mnemonic {
                        // 显示 MnemonicView
                        MnemonicView(mnemonic: mnemonicPhrase, password: password)
                                .environmentObject(appState)
                } else {
                        ZStack {
                                Color.white
                                        .ignoresSafeArea(edges: .all) // 确保背景填充整个屏幕
                                
                                VStack(spacing: 0){
                                        VStack(spacing: 0){
                                                // Section 1
                                                ZStack(alignment: .topLeading) {
                                                        // 背景图片
                                                        Image("password-img")
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: UIScreen.main.bounds.width, height: 215)
                                                                .clipped()
                                                        
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
                                        }
                                        .id("image and tittle")
                                        .frame(maxWidth: .infinity)
                                        
                                        // Section 2 (覆盖部分)
                                        VStack(spacing: 24) {
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
                                        }.id("password area")
                                                .background(Color.red.opacity(0.2))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .id("main container")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // 对齐顶部
                                .contentShape(Rectangle()) // 确保手势覆盖整个区域
                                .onTapGesture {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                                dismiss()
                                        }) {
                                                Image("back_icon")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, height: 24)
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
