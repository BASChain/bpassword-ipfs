import SwiftUI

struct MnemonicView: View {
        let mnemonic: String
        let password: String
        @State private var isButtonPressed: Bool = false
        @State private var errorMessage: String? = nil
        @Environment(\.dismiss) private var dismiss
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                                // 主标题
                                Text("Backup Your\nMnemonic Phrase")
                                        .font(.system(size: 28, weight: .bold)) // 对应 `font-size: 28px` 和 `font-weight: 700`
                                        .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255)) // 对应 `color: rgba(25, 25, 29, 1)`
                                        .lineSpacing(6) // 设置行间距
                                        .multilineTextAlignment(.leading) // 左对齐
                                        .frame(width: 251, alignment: .leading) // 固定宽度，左对齐
                                
                                // 副标题
                                Text("Keep this phrase secure and offline.\nIt is the only way to recover your wallet.")
                                        .font(.custom("Helvetica", size: 16)) // 使用 Helvetica 字体，`font-size: 16px`
                                        .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255)) // 对应 `color: rgba(137, 145, 155, 1)`
                                        .lineSpacing(4) // 调整行间距为 4
                                        .multilineTextAlignment(.leading) // 左对齐
                                        .frame(width: 279, alignment: .leading) // 固定宽度，左对齐
                        }
                        .padding(.top, 32) // 设置顶部间距，适配设计图
                        .padding(.leading, 22) // 设置左边距
                        
                        // 助记词显示区域
                        ZStack {
                                if isButtonPressed {
                                        // 显示助记词
                                        Text(mnemonic)
                                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .frame(width: 327, height: 204)
                                                .background(Color(red: 20/255, green: 36/255, blue: 54/255)) // 深蓝背景
                                                .cornerRadius(31)
                                } else {
                                        // 显示默认图片
                                        Image("backup-img")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 327, height: 204)
                                                .cornerRadius(31)
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // 长按按钮区域
                        Button(action: {}) {
                                Text("Press and Hold to View Mnemonic")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(31)
                        }
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                if !LoadingManager.shared.isVisible {
                                        withAnimation {
                                                isButtonPressed = isPressing
                                        }
                                }
                        }, perform: {})
                        
                        // 按钮区域
                        VStack(spacing: 16) {
                                // 复制助记词按钮
                                Button(action: copyMnemonic) {
                                        Text("Copy Mnemonic")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255)) // 深蓝文字
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color(red: 255/255, green: 161/255, blue: 54/255)) // 橙色背景
                                                .cornerRadius(31)
                                }
                                .padding(.horizontal, 24)
                                
                                // 已备份按钮
                                Button(action: createWallet) {
                                        Text("I have backed up my mnemonic")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color(red: 15/255, green: 211/255, blue: 212/255)) // 浅蓝背景
                                                .cornerRadius(31)
                                }
                                .padding(.horizontal, 24)
                        }
                        
                        if let error = errorMessage {
                                Text(error)
                                        .foregroundColor(.red)
                                        .padding()
                        }
                        
                        Spacer()
                }
                .padding()
                .background(Color.white) // 页面背景 
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
        
        private func copyMnemonic() {
                UIPasteboard.general.string = mnemonic
                SdkUtil.shared.toastManager?.showToast(message: "Mnemonic copied!", isSuccess: true)
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
