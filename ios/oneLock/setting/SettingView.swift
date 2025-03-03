import SwiftUI

struct SettingView: View {
        @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
        @State private var isCopySuccess: Bool = false
        @State private var showBottomSheet: Bool = false
        @State private var showAlert: Bool = false
        @State private var showPasswordPrompt: Bool = false
        @State private var navigateToMnemonic: Bool = false
        @State private var mnemonicVal: String = ""
        
        let blockchainAddress: String = SdkUtil.shared.walletAddress()
        
        var body: some View {
                NavigationView {
                        ScrollView {
                                VStack(spacing: 16) {
                                        BlockchainAddressView(address: blockchainAddress, copyAction: copyToClipboard)
                                        
                                        AutoCloseAndMnemonicView(autoCloseDuration: $autoCloseDuration,
                                                                 showBottomSheet: $showBottomSheet,
                                                                 showPasswordPrompt: $showPasswordPrompt)
                                        
                                        VersionAndShareView()
                                        
                                        AccountActionsView(showAlert: $showAlert)
                                        
                                        // 隐藏的 NavigationLink，当 navigateToMnemonic 为 true 时触发跳转
                                        NavigationLink(
                                                destination: MnemonicView(mnemonic: mnemonicVal, password: ""),
                                                isActive: $navigateToMnemonic,
                                                label: { EmptyView() }
                                        )
                                }
                                .background(Color.white.edgesIgnoringSafeArea(.all))
                                .navigationBarTitle("Settings", displayMode: .inline)
                        }
                        .overlay(
                                BottomSheet(show: $showBottomSheet, autoCloseDuration: $autoCloseDuration)
                        )
                        .overlay(
                                GenericAlertView(
                                        isPresented: $showAlert,
                                        title: "Confirm Deletion",
                                        message: "Are you sure you want to delete this account?",
                                        onConfirm: deleteAccount,
                                        onCancel: { showAlert = false }
                                )
                        ).overlay(
                                Group {
                                        if showPasswordPrompt {
                                                PasswordPromptView(isPresented: $showPasswordPrompt, onPasswordSubmit: { password in
                                                        validatePassword(password)
                                                })
                                        }
                                }
                        )
                }
        }
        
        private func copyToClipboard() {
                UIPasteboard.general.string = blockchainAddress
                withAnimation { isCopySuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { isCopySuccess = false }
                }
        }
        
        private func deleteAccount() {
                LoadingManager.shared.show(message: "Deleting Account......")
                DispatchQueue.global().async {
                        SdkUtil.shared.deleteAccount()
                        LoadingManager.shared.hide()
                }
        }
        
        private func validatePassword(_ password: String) {
                LoadingManager.shared.show(message: "Decrypting......")
                DispatchQueue.global().async {
                        do{
                                mnemonicVal = try SdkUtil.shared.showMnemonic(password: password)
                                LoadingManager.shared.hide()
                                navigateToMnemonic = true
                        }catch{
                                LoadingManager.shared.hide()
                                SdkUtil.shared.toastManager?.showToast(message: "Failed:\(error.localizedDescription)", isSuccess: false)
                                print("------>>>Show mnemonic error: \(error.localizedDescription)")
                                navigateToMnemonic = false
                        }
                }
        }
}

// MARK: - 子视图

struct BlockchainAddressView: View {
        let address: String
        let copyAction: () -> Void
        
        var body: some View {
                ZStack(alignment: .topLeading) {
                        Image("blockchain_background")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 105)
                                .cornerRadius(16)
                        VStack(alignment: .leading, spacing: 8) {
                                Text("Your Blockchain Address:")
                                        .font(.custom("HelveticaNeue-Medium", size: 18))
                                        .foregroundColor(Color(red: 15/255, green: 211/255, blue: 212/255))
                                HStack {
                                        Text(address)
                                                .font(.custom("Helvetica", size: 12))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        Button(action: copyAction) {
                                                Image("copy-Mnemonic") // 可根据 isCopySuccess 状态替换图标
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 30, height: 30)
                                        }
                                        .padding(.leading, 8)
                                }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
        }
}

struct AutoCloseAndMnemonicView: View {
        @Binding var autoCloseDuration: Int
        @Binding var showBottomSheet: Bool
        @Binding var showPasswordPrompt: Bool
        
        var body: some View {
                VStack(spacing: 0) {
                        HStack {
                                Text("Auto Close Wallet Duration")
                                        .font(.custom("SFProText-Medium", size: 15))
                                        .foregroundColor(.black)
                                Spacer()
                                Button(action: { showBottomSheet.toggle() }) {
                                        HStack {
                                                Text("\(autoCloseDuration) Mins")
                                                        .font(.custom("HelveticaNeue-Medium", size: 14))
                                                        .foregroundColor(.black)
                                                Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                        }
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        
                        Divider().background(Color.gray.opacity(0.05))
                        
                        NavigationLink(destination: PasswordChangeView()) {
                                HStack {
                                        Text("Change Password")
                                                .font(.custom("SFProText-Medium", size: 15))
                                                .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 11, height: 11)
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        
                        Divider().background(Color.gray.opacity(0.05))
                        
                        Button(action: {
                                showPasswordPrompt = true
                        }) {
                                HStack {
                                        Text("Show Mnemonic")
                                                .font(.custom("SFProText-Medium", size: 15))
                                                .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 11, height: 11)
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                }
                .background(Rectangle().fill(Color.gray.opacity(0.05)))
                .cornerRadius(10)
        }
}

struct VersionAndShareView: View {
        var body: some View {
                VStack(spacing: 0) {
                        HStack {
                                Text("Current Version")
                                        .font(.custom("SFProText-Medium", size: 15))
                                        .foregroundColor(.black)
                                Spacer()
                                Text(SdkUtil.shared.getVersion())
                                        .font(.custom("SFProText-Regular", size: 14))
                                        .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                        .cornerRadius(10)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        
                        Divider().background(Color.gray.opacity(0.05))
                        
                        Button(action: {
                                SdkUtil.shared.toastManager?.showToast(message: "Share App", isSuccess: true)
                        }) {
                                HStack {
                                        Text("Share This App")
                                                .font(.custom("SFProText-Medium", size: 15))
                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                        Spacer()
                                        Image("share_icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                }
                .background(Rectangle().fill(Color.gray.opacity(0.05)))
                .cornerRadius(10)
        }
}

struct AccountActionsView: View {
        @Binding var showAlert: Bool
        
        var body: some View {
                VStack(spacing: 12) {
                        Button(action: { showAlert = true }) {
                                HStack {
                                        Text("Delete Account")
                                                .font(.custom("SFProText-Medium", size: 15))
                                                .foregroundColor(Color(red: 255/255, green: 161/255, blue: 54/255))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 11, height: 11)
                                                .foregroundColor(.gray)
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        
                        Divider().background(Color.gray.opacity(0.05))
                        
                        Button(action: {
                                SdkUtil.shared.logout()
                        }) {
                                Text("Log Out")
                                        .font(.custom("SFProText-Medium", size: 16))
                                        .foregroundColor(Color(red: 0, green: 188/255, blue: 212/255))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(red: 0, green: 188/255, blue: 212/255, opacity: 0.15))
                                        .cornerRadius(10)
                        }
                        .padding(.horizontal, 22)
                }
                .background(Rectangle().fill(Color.gray.opacity(0.05)))
                .cornerRadius(10)
        }
}

