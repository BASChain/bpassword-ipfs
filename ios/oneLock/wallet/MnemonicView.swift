import SwiftUI

struct MnemonicView: View {
        let mnemonic: String
        let password: String
        @State private var isButtonPressed: Bool = false
        @State private var errorMessage: String? = nil
        
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                VStack(spacing: 20) {
                        Text("Backup Your Mnemonic Phrase")
                                .font(.headline)
                                .padding(.top)
                        
                        Text("Keep this phrase secure and offline. It is the only way to recover your wallet.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        
                        ZStack {
                                ScrollView {
                                        Text(mnemonic)
                                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(10)
                                                .opacity(isButtonPressed ? 1.0 : 0.0)
                                }
                                .frame(height: 150)
                                
                                if !isButtonPressed {
                                        Color.black.opacity(0.7)
                                                .cornerRadius(10)
                                                .frame(height: 150)
                                        Text("Press and Hold to View")
                                                .foregroundColor(.white)
                                                .font(.body)
                                                .bold()
                                }
                        }
                        .padding()
                        
                        Button(action: {}) {
                                Text("Press and Hold to View Mnemonic")
                        }
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                if !LoadingManager.shared.isVisible {
                                        withAnimation {
                                                isButtonPressed = isPressing
                                        }
                                }
                        }, perform: {})
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button(action: copyMnemonic) {
                                Text("Copy Mnemonic")
                        }
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button(action: createWallet) {
                                Text("I have backed up my mnemonic")
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        if let error = errorMessage {
                                Text(error)
                                        .foregroundColor(.red)
                                        .padding()
                        }
                }
                .padding()
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
