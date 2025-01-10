import SwiftUI

struct MnemonicView: View {
        let mnemonic: String
        let password: String
        @State private var isButtonPressed: Bool = false
        @State private var errorMessage: String? = nil
        @Environment(\.dismiss) private var dismiss
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var appState: AppState
        @State private var isCopied: Bool = false // 跟踪是否已经复制
        
        var body: some View {
                GeometryReader { geometry in
                        VStack() {
                                Spacer() .frame(height:40)
                                VStack() {
                                        // 主标题
                                        Text("Backup Your\nMnemonic Phrase")
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                                .lineSpacing(geometry.size.height * 0.005)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer() .frame(height:8)
                                        // 副标题
                                        Text("Keep this phrase secure and offline.\nIt is the only way to recover your wallet.")
                                                .font(.custom("Helvetica", size: 16))
                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                .lineSpacing(geometry.size.height * 0.005)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                } .padding(.horizontal, 22)
                                
                                
                                Spacer() .frame(height:50)
                                // 助记词显示区域
                                ZStack {
                                        if isButtonPressed {
                                                Text(mnemonic)
                                                        .font(.system(size: geometry.size.height * 0.025, weight: .bold, design: .monospaced))
                                                        .foregroundColor(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                        .multilineTextAlignment(.center)
                                                        .padding()
                                                        .frame(height:212)
                                                        .background(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                        .cornerRadius(geometry.size.height * 0.02)
                                        } else {
                                                Image("menemonic-img")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(height:212)
                                                        .cornerRadius(geometry.size.height * 0.02)
                                        }
                                }
                                .padding(.horizontal, 16)
                                
                                Spacer() .frame(height:8)
                                // 复制按钮
                                Button(action: copyMnemonic) {
                                        HStack {
                                                if isCopied {
                                                        Image("copy-success")
                                                        Text("Copy Success")
                                                                .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                } else {
                                                        Image("copy-Mnemonic")
                                                        Text("Copy Mnemonic")
                                                                .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                }
                                        }
                                }.frame(width:157,height:30,alignment: .center)
                                        .padding(.horizontal, 32)
                                        .background(Color(red: 41/255, green: 97/255, blue: 97/255).opacity(0.2))
                                        .cornerRadius(17)
                                        .overlay(
                                                RoundedRectangle(cornerRadius: 17)
                                                        .stroke(Color(red: 0.6, green: 0.8, blue: 0.9), lineWidth: 1)
                                        )
                                
                                Spacer() .frame(height:40)
                                
                                // 长按按钮
                                Button(action: {}) {
                                        Text("Press and Hold to View Mnemonic")
                                                .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.orange)
                                                .cornerRadius(geometry.size.height * 0.03)
                                }
                                .padding(.horizontal, 16)
                                .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                        if !LoadingManager.shared.isVisible {
                                                withAnimation {
                                                        isButtonPressed = isPressing
                                                }
                                        }
                                }, perform: {})
                                Spacer() .frame(height:16)
                                // 已备份按钮
                                Button(action: createWallet) {
                                        Text("I have backed up my mnemonic")
                                                .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                .cornerRadius(geometry.size.height * 0.03)
                                }
                                .padding(.horizontal, 16)
                                
                                if let error = errorMessage {
                                        Text(error)
                                                .foregroundColor(.red)
                                                .padding()
                                }
                                Spacer()
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
                }
        }
        
        private func copyMnemonic() {
                UIPasteboard.general.string = mnemonic
                isCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        isCopied = false
                }
        }
        
        private func createWallet() {
                errorMessage = nil
                LoadingManager.shared.show(message: "Creating Wallet...")
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.createWallet(mnemonic: mnemonic, password: password)
                        
                        DispatchQueue.main.async {
                                LoadingManager.shared.hide()
                                
                                if success {
                                        appState.hasWallet = true
                                } else {
                                        errorMessage = "Failed to create wallet. Please try again."
                                }
                        }
                }
        }
}
