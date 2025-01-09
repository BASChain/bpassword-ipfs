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
        @State private var keyboardOffset: CGFloat = 0 // 输入区域的键盘偏移量
        @State private var isPasswordVisible: Bool = false
        @State private var isConfirmPasswordVisible: Bool = false
        
        var body: some View {
                GeometryReader { geometry in
                        VStack(spacing: 0) {
                                // 顶部背景和标题
                                ZStack(alignment: .topLeading) {
                                        Image("import-img")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 262)
                                                .clipped()
                                                .ignoresSafeArea(edges: .top)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                                Text("Import Wallet")
                                                        .font(.system(size: 28, weight: .bold))
                                                        .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                        .lineSpacing(6)
                                        }
                                        .padding(.top, 100)
                                        .padding(.leading, 24)
                                }
                                .frame(height: 262 - geometry.safeAreaInsets.top - 40)
                                
                                // 输入区域
                                VStack(spacing: 16) {
                                        Text("Entire secret recovery phrase")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        TextEditor(text: $mnemonic)
                                                .scrollContentBackground(.hidden) // 确保隐藏默认背景
                                                .font(.custom("Helvetica", size: 16))
                                                .foregroundColor(Color(red: 61/255, green: 147/255, blue: 147/255))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .leading)
                                                .background(Color(red: 203/255, green: 233/255, blue: 232/255)) // 设置浅绿色背景
                                                .cornerRadius(31)
                                                .overlay(
                                                        RoundedRectangle(cornerRadius: 31)
                                                                .stroke(Color(red: 203/255, green: 233/255, blue: 232/255), lineWidth: 2)
                                                )
                                        
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
                                        
                                        Text("Confirm Password")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        
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
                                }
                                .padding()
                                .background(
                                        RoundedCornersShape(corners: [.topLeft, .topRight], radius: 32)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                                )
                                .offset(y: keyboardOffset)
                                .animation(.easeOut, value: keyboardOffset)
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
                .onAppear {
                        addKeyboardObservers()
                }
                .onDisappear {
                        removeKeyboardObservers()
                }
        }
        
        private func importWallet() {
                if mnemonic.isEmpty {
                        errorMessage = "Mnemonic cannot be empty."
                } else if password != confirmPassword || password.isEmpty {
                        errorMessage = "Passwords do not match or are empty."
                } else {
                        errorMessage = nil
                        LoadingManager.shared.show(message: "Creating Wallet...")
                        DispatchQueue.global().async {
                                let success = SdkUtil.shared.createWallet(mnemonic: mnemonic, password: password)
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        if success {
                                                appState.hasWallet = true
                                                presentationMode.wrappedValue.dismiss()
                                        } else {
                                                errorMessage = "Failed to create wallet. Please try again."
                                        }
                                }
                        }
                }
        }
        
        private func addKeyboardObservers() {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                let keyboardHeight = keyboardFrame.height
                                keyboardOffset = -keyboardHeight / 2
                        }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        keyboardOffset = 0
                }
        }
        
        private func removeKeyboardObservers() {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
}
