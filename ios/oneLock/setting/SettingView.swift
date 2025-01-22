import SwiftUI

struct SettingView: View {
        @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
        @State private var isCopySuccess: Bool = false // 状态控制图标变化
        @State private var showBottomSheet: Bool = false // 用于控制底部弹出视图
        let blockchainAddress: String = SdkUtil.shared.walletAddress()
        
        var body: some View {
                NavigationView {
                        ScrollView {
                                VStack(spacing: 16) {
                                        // 区块链地址部分
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
                                                                Text(blockchainAddress)
                                                                        .font(.custom("Helvetica", size: 12))
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(1)
                                                                        .truncationMode(.middle)
                                                                
                                                                // 添加复制按钮
                                                                Button(action: copyToClipboard) {
                                                                        Image(isCopySuccess ? "copy-success" : "copy-Mnemonic")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .frame(width: 30, height: 30)
                                                                }
                                                                .padding(.leading, 8)
                                                        }
                                                }
                                                .padding(.top, 16)
                                                .padding(.leading, 22)
                                                .padding(.bottom, 24)
                                                .padding(.trailing, 22)
                                        }
                                        .padding(.horizontal, 22)
                                        .padding(.top, 20) // 距离顶部间距
                                        
                                        // Group 1: Auto Close Wallet Duration and Change Password
                                        VStack(spacing: 0) {
                                                HStack {
                                                        Text("Auto Close Wallet Duration")
                                                                .font(.custom("SFProText-Medium", size: 15))
                                                                .foregroundColor(.black)
                                                        Spacer()
                                                        Button(action: {
                                                                showBottomSheet.toggle()
                                                        }) {
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
                                        }
                                        .background(Rectangle().fill(Color.gray.opacity(0.05)))
                                        .cornerRadius(10)
                                        
                                        // Group 2: Current Version and Share This App
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
                                                        shareApp()
                                                }) {
                                                        HStack {
                                                                Text("Share This App")
                                                                        .font(.custom("SFProText-Medium", size: 15))
                                                                        .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                                Spacer()
                                                                Image("share_icon")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 16, height: 16)
                                                        }
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 22)
                                        }
                                        .background(Rectangle().fill(Color.gray.opacity(0.05)))
                                        .cornerRadius(10)
                                        
                                        // Group 3: Delete Account and Log Out
                                        VStack(spacing: 12) {
                                                Button(action: {
                                                        deleteAccount()
                                                }) {
                                                        HStack {
                                                                Text("Delete Account")
                                                                        .font(.custom("SFProText-Medium", size: 15))
                                                                        .foregroundColor(.red)
                                                                Spacer()
                                                                Image(systemName: "trash")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 16, height: 16)
                                                                        .foregroundColor(.red)
                                                        }
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 22)
                                                
                                                Divider().background(Color.gray.opacity(0.05))
                                                
                                                Button(action: {
                                                        logOut()
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
                        .background(Color.white.edgesIgnoringSafeArea(.all))
                        .navigationBarTitle("Settings", displayMode: .inline)
                }
                .overlay(
                        BottomSheet(show: $showBottomSheet, autoCloseDuration: $autoCloseDuration)
                )
        }
        
        private func copyToClipboard() {
                UIPasteboard.general.string = blockchainAddress
                withAnimation {
                        isCopySuccess = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                                isCopySuccess = false
                        }
                }
        }
        
        private func shareApp() {
                guard let url = URL(string: SdkUtil.AppUrl) else { return }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(activityVC, animated: true, completion: nil)
                } else {
                        SdkUtil.shared.toastManager?.showToast(message: "Share Failed!", isSuccess: false)
                }
        }
        
        private func deleteAccount() {
                // Add account deletion logic here
                SdkUtil.shared.toastManager?.showToast(message: "Account Deleted", isSuccess: true)
        }
        
        private func logOut() {
                // Add logout logic here
                SdkUtil.shared.toastManager?.showToast(message: "Logged Out", isSuccess: true)
        }
}

struct BottomSheet: View {
        @Binding var show: Bool
        @Binding var autoCloseDuration: Int
        
        var body: some View {
                if show {
                        VStack {
                                Spacer()
                                VStack(spacing: 0) {
                                        HStack {
                                                Text("Auto close Wallet Duration")
                                                        .font(.headline)
                                                        .padding()
                                                Spacer()
                                                Button(action: {
                                                        show = false
                                                }) {
                                                        Image("close").padding()
                                                }
                                        }
                                        .background(Color.white)
                                        
                                        Divider()
                                        
                                        ForEach([1, 5, 10, 15, 30, 60], id: \ .self) { value in
                                                HStack {
                                                        Text("\(value) Mins")
                                                                .font(.body)
                                                                .padding()
                                                        Spacer()
                                                        if value == autoCloseDuration {
                                                                Image("checked_icon")
                                                        }
                                                }
                                                .background(Color.white)
                                                .onTapGesture {
                                                        changeCloseDuration(value:value)
                                                }
                                                Divider()
                                        }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(radius: 10)
                        }
                        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: show)
                }
        }
        
        private func changeCloseDuration(value:Int){
                
                
                autoCloseDuration = value
                do{
                        try SdkUtil.shared.setAutoCloseDuration(value)
                        SdkUtil.shared.toastManager?.showToast(message: "Save Success!", isSuccess: true)
                        show = false
                }catch{
                        SdkUtil.shared.toastManager?.showToast(message: "Save Failed!", isSuccess: false)
                }
        }
}
