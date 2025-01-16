import SwiftUI

struct ImportWalletView: View {
        init() {
                UITextView.appearance().backgroundColor = UIColor.clear // 强制清除 UITextView 的默认白色背景
        }
        
        @EnvironmentObject var appState: AppState
        @Environment(\.presentationMode) var presentationMode
        
        @State private var mnemonic: String = ""
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @State private var isPasswordVisible: Bool = false
        @State private var isConfirmPasswordVisible: Bool = false
        
        var body: some View {
                GeometryReader { geometry in
                        VStack(spacing: 0) {
                                // 顶部背景和标题
                                ZStack(alignment: .topLeading) {
                                        Image("import-img")
                                                .resizable()
                                                .scaledToFill() // 确保图片填充整个区域
//                                                .frame(width: geometry.size.width, height: geometry.size.height * 0.3) // 减去顶部安全区高度
                                                .clipped() // 防止图片溢出
                                                .frame(height: 262)
                                                .ignoresSafeArea(edges: .top)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                                Text("Import Wallet")
                                                        .font(.system(size: 28, weight: .bold))
                                                        .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                        .lineSpacing(6)
                                        }
                                        .padding(.top, geometry.size.height / 8)
                                        .padding(.leading, 24)
                                }
                                .frame(height: 262 - geometry.safeAreaInsets.top - 40)
                                
                                // 输入区域
                                VStack(spacing: 16) {
                                        Text("Entire secret recovery phrase")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 35) // 设置顶端距离
                                        
                                        if #available(iOS 16.0, *) {
                                                TextEditor(text: $mnemonic)
                                                        .scrollContentBackground(.hidden) // 确保隐藏默认背景
                                                        .font(.custom("Helvetica", size: 16))
                                                        .foregroundColor(Color(red: 61/255, green: 147/255, blue: 147/255))
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 12)
                                                        .frame(height: 120) // 设置固定高度为 50pt
                                                        .fixedSize(horizontal: false, vertical: true) // 禁止垂直扩展
                                                        .background(Color(red: 203/255, green: 233/255, blue: 232/255)) // 设置浅绿色背景
                                                        .cornerRadius(31)
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 31)
                                                                        .stroke(Color(red: 203/255, green: 233/255, blue: 232/255), lineWidth: 2)
                                                        )
                                        } else {
                                                TextEditor(text: $mnemonic)
                                                        .font(.custom("Helvetica", size: 16))
                                                        .foregroundColor(Color(red: 61/255, green: 147/255, blue: 147/255))
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 12)
                                                        .frame(height: 120) // 设置固定高度为 50pt
                                                        .fixedSize(horizontal: false, vertical: true) // 禁止垂直扩展
                                                        .background(Color(red: 203/255, green: 233/255, blue: 232/255)) // 设置浅绿色背景
                                                        .cornerRadius(31)
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 31)
                                                                        .stroke(Color(red: 203/255, green: 233/255, blue: 232/255), lineWidth: 2)
                                                        )
                                        }
                                        
                                        Text("Password")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                                if isPasswordVisible {
                                                        TextField("Enter Password", text: $password)
                                                                .padding()
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                                .disableAutocorrection(true)
                                                                .textContentType(.oneTimeCode)
                                                } else {
                                                        SecureField("Enter Password", text: $password)
                                                                .padding()
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                                .disableAutocorrection(true)
                                                                .textContentType(.oneTimeCode)
                                                }
                                                
                                                Button(action: {
                                                        isPasswordVisible.toggle()
                                                }) {
                                                        Image(isPasswordVisible ? "opened-gray-icon" : "closed-icon")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 20, height: 20)
                                                }
                                                .padding(.trailing, 16)
                                        }
                                        
                                        HStack {
                                                if isConfirmPasswordVisible {
                                                        TextField("Confirm Password", text: $confirmPassword)
                                                                .padding()
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                                .disableAutocorrection(true)
                                                                .textContentType(.oneTimeCode)
                                                } else {
                                                        SecureField("Confirm Password", text: $confirmPassword)
                                                                .padding()
                                                                .frame(height: 50)
                                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                                .disableAutocorrection(true)
                                                                .textContentType(.oneTimeCode)
                                                }
                                                
                                                Button(action: {
                                                        isConfirmPasswordVisible.toggle()
                                                }) {
                                                        Image(isConfirmPasswordVisible ? "opened-gray-icon" : "closed-icon")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 20, height: 20)
                                                }
                                                .padding(.trailing, 16)
                                        }
                                        
                                        if let errorMessage = errorMessage {
                                                Text(errorMessage)
                                                        .foregroundColor(.red)
                                                        .font(.system(size: 14))
                                                        .padding(.top, 8)
                                        }
                                        
                                        Button(action: {
                                                importWallet()
                                        }) {
                                                RoundedRectangle(cornerRadius: 31)
                                                        .fill(Color.orange)
                                                        .frame(height: 50)
                                                        .overlay(
                                                                Text("Import Wallet")
                                                                        .font(.system(size: 16, weight: .semibold))
                                                                        .foregroundColor(.white)
                                                        )
                                        }
                                        Spacer()
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
                                                presentationMode.wrappedValue.dismiss()
                                        }) {
                                                Image("back_icon")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(.black)
                                        }
                                }
                        }
                        .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
        }
        
        private func importWallet() {
                if mnemonic.isEmpty {
                        errorMessage = "Mnemonic cannot be empty."
                } else if password.count < 8 {
                        errorMessage = "Password must be at least 8 characters."
                } else if password != confirmPassword || password.isEmpty {
                        errorMessage = "Passwords do not match or are empty."
                } else {
                        errorMessage = nil
                        LoadingManager.shared.show(message: "Creating Wallet...")
                        DispatchQueue.global().async {
                                
                                do {
                                        try SdkUtil.shared.createWallet(mnemonic: mnemonic, password: password)
                                        LoadingManager.shared.hide()
                                        DispatchQueue.main.async { // 隐藏加载提示
                                                appState.hasWallet = true
                                                presentationMode.wrappedValue.dismiss()
                                        }
                                        
                                } catch {
                                        LoadingManager.shared.hide()
                                        DispatchQueue.main.async {
                                                errorMessage = "Failed to create wallet. Please try again."
                                        }
                                }
                        }
                }
        }
}
