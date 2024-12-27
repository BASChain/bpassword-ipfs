import SwiftUI

struct ImportWalletView: View {
        @EnvironmentObject var appState: AppState
        @Environment(\.presentationMode) var presentationMode // 添加 presentationMode
        
        @State private var mnemonic: String = ""
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var errorMessage: String? = nil
        @StateObject private var loadingManager = LoadingManager() // 添加 LoadingManager 实例
        
        var body: some View {
                ZStack {
                        VStack {
                                Text("Import Wallet")
                                        .font(.largeTitle)
                                        .padding()
                                
                                TextEditor(text: $mnemonic)
                                        .font(.body)
                                        .padding()
                                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                        SecureField("Enter Password", text: $password)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        SecureField("Confirm Password", text: $confirmPassword)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                .padding()
                                
                                if let errorMessage = errorMessage {
                                        Text(errorMessage)
                                                .foregroundColor(.red)
                                                .padding()
                                }
                                
                                Button("Import") {
                                        importWallet()
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        .navigationTitle("Import Wallet")
                        
                        // 显示加载提示
                        LoadingView(isVisible: $loadingManager.isVisible, message: $loadingManager.message)
                }
        }
        
        private func importWallet() {
                // Mock validation for mnemonic and passwords
                if mnemonic.isEmpty {
                        errorMessage = "Mnemonic cannot be empty."
                } else if password != confirmPassword || password.isEmpty {
                        errorMessage = "Passwords do not match or are empty."
                } else {
                        errorMessage = nil
                        
                        loadingManager.show(message: "Creating Wallet...") // 显示加载提示
                        
                        DispatchQueue.global().async {
                                let success = SdkUtil.shared.createWallet(mnemonic: mnemonic, password: password)
                                
                                DispatchQueue.main.async {
                                        loadingManager.hide() // 隐藏加载提示
                                        
                                        if success {
                                                appState.hasWallet = true
                                                presentationMode.wrappedValue.dismiss() // 成功后关闭视图
                                        } else {
                                                errorMessage = "Failed to create wallet. Please try again."
                                        }
                                }
                        }
                }
        }
}
