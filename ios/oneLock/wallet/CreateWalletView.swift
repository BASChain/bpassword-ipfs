import SwiftUI

struct CreateWalletView: View {
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        
        var body: some View {
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
                                
                                Spacer() // 为了占据剩余的空间
                        }
                        
                        // Section 2 (覆盖部分)
                        ZStack {
                                // 背景颜色和圆角
                                RoundedRectangle(cornerRadius: 31)
                                        .fill(Color.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: -2)
                                
                                VStack(spacing: 16) {
                                        // 输入框 1
                                        SecureField("Enter Password", text: $password)
                                                .padding()
                                                .frame(height: 50)
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                        
                                        // 输入框 2
                                        SecureField("Confirm Password", text: $confirmPassword)
                                                .padding()
                                                .frame(height: 50)
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                        
                                        // 按钮
                                        Button(action: {
                                                print("Password: \(password)")
                                                print("Confirm Password: \(confirmPassword)")
                                        }) {
                                                RoundedRectangle(cornerRadius: 31)
                                                        .fill(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                        .frame(height: 50)
                                                        .overlay(
                                                                Text("Generate Wallet")
                                                                        .font(.system(size: 16, weight: .semibold))
                                                                        .foregroundColor(.white)
                                                        )
                                        }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 47)
                        }
                        .frame(height: 597)
                        .offset(y: 107) // 调整 Section 2 向上覆盖 Section 1 的底部
                }
                .contentShape(Rectangle()) // 确保手势覆盖整个区域
                .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
}

struct CreateWalletView_Previews: PreviewProvider {
        static var previews: some View {
                CreateWalletView()
                        .previewLayout(.sizeThatFits)
        }
}
