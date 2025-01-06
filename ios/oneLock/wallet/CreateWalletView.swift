import SwiftUI

// 自定义形状，仅为指定的角应用圆角
struct RoundedCornersShape: Shape {
        var corners: UIRectCorner
        var radius: CGFloat
        
        func path(in rect: CGRect) -> Path {
                let path = UIBezierPath(
                        roundedRect: rect,
                        byRoundingCorners: corners,
                        cornerRadii: CGSize(width: radius, height: radius)
                )
                return Path(path.cgPath)
        }
}

struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var mnemonic: String? = nil
        @EnvironmentObject var appState: AppState
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
                if let mnemonicPhrase = mnemonic {
                        // 显示 MnemonicView
                        MnemonicView(mnemonic: mnemonicPhrase, password: password)
                                .environmentObject(appState)
                } else {
                        GeometryReader { geometry in
                                VStack(spacing: 0) {
                                        // 顶部图片和标题
                                        ZStack(alignment: .topLeading) {
                                                Image("password-img")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(height: 262)
                                                        .clipped()
                                                        .ignoresSafeArea(edges: .top)
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                        Text("Create\nAccount")
                                                                .font(.system(size: 28, weight: .bold))
                                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                                .lineSpacing(6)
                                                }
                                                // 调整标题的顶部 padding，减去安全区域高度
                                                .padding(.top, 100)
                                                .padding(.leading, 21)
                                        }
                                        // 设置父容器高度为120
                                        .frame(height: 262 - geometry.safeAreaInsets.top - 40)
                                        
                                        // 密码输入区域
                                        VStack(spacing: 24) {
                                                SecureField("Enter Password", text: $password)
                                                        .padding(.horizontal, 16)
                                                        .frame(height: 50)
                                                        .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                        .cornerRadius(24)
                                                        .font(.system(size: 16))
                                                        .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255))
                                                
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
                                                }
                                                
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
                                                
                                                Spacer()
                                        }
                                        .padding()
                                        .background(
                                                // 应用自定义圆角形状，仅对顶部两个角应用圆角
                                                RoundedCornersShape(corners: [.topLeft, .topRight], radius: 32)
                                                        .fill(Color.white)
                                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                                        )
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .background(Color.white)
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
                                .onTapGesture {
                                        // 点击空白处收起键盘
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
