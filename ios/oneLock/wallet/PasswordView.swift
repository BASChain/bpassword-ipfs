import SwiftUI

struct PasswordView: View {
        @State private var password: String = ""
        @State private var errorMessage: String? = nil
        
        @Environment(\.dismiss) private var dismiss
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                NavigationView { // 添加 NavigationView
                        GeometryReader { geometry in
                                VStack(spacing: 0) {
                                        // 顶部背景和标题
                                        ZStack(alignment: .topLeading) {
                                                Image("password-img")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(height: 262)
                                                        .clipped()
                                                        .ignoresSafeArea(edges: .top)
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                        Text("Enter Password\nfor Wallet")
                                                                .font(.system(size: 28, weight: .bold))
                                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                                .lineSpacing(6)
                                                }
                                                // 调整标题的顶部 padding，减去安全区域高度
                                                .padding(.top, 100)
                                                .padding(.leading, 21)
                                        }
                                        .frame(height: 262 - geometry.safeAreaInsets.top - 40)
                                        
                                        // 密码输入区域
                                        VStack(spacing: 16) {
                                                SecureField("Enter Password", text: $password)
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
                                                        validatePassword()
                                                }) {
                                                        RoundedRectangle(cornerRadius: 31)
                                                                .fill(Color(red: 15 / 255, green: 211 / 255, blue: 212 / 255))
                                                                .frame(height: 50)
                                                                .overlay(
                                                                        Text("Open Wallet")
                                                                                .font(.system(size: 16, weight: .semibold))
                                                                                .foregroundColor(.white)
                                                                )
                                                }
                                                
                                                NavigationLink(destination: ImportWalletView().environmentObject(appState)) {
                                                        Text("Forget Password")
                                                                .font(.system(size: 14))
                                                                .foregroundColor(Color(red: 137 / 255, green: 145 / 255, blue: 155 / 255))
                                                                .frame(maxWidth: .infinity, alignment: .trailing) // 调整为右对齐
                                                                .padding(.trailing, 24) // 右边增加 24px 的间距
                                                }
                                                .padding(.top, 8) // 与“Open Wallet”按钮保持适当间距
                                                
                                                Spacer() // 将内容与底部留出空间
                                        }
                                        .padding()
                                        .background(
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
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                }
        }
        
        private func validatePassword() {
                errorMessage = nil
                LoadingManager.shared.show(message: "Decoding Wallet...")
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.openWallet(password: password)
                        
                        DispatchQueue.main.async {
//                                LoadingManager.shared.hide() // 隐藏加载提示
                                if success {
                                        appState.isPasswordValidated = true
                                } else {
                                        errorMessage = "Invalid Password. Please try again."
                                }
                        }
                }
        }
}
