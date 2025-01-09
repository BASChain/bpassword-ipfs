import SwiftUI

struct SettingView: View {
        @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
        @State private var isCopySuccess: Bool = false // 状态控制图标变化
        @State private var showBottomSheet: Bool = false // 用于控制底部弹出视图
        let blockchainAddress: String = SdkUtil.shared.walletAddress()
        
        var body: some View {
                NavigationView {
                        ScrollView {
                                VStack(spacing: 0) {
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
                                                                                .frame(width: 20, height: 20)
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
                                        
                                        // Auto Close Wallet Duration
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
                                                
                                                Divider()
                                                        .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                        .padding(.horizontal, 22)
                                        }
                                        
                                        // Change Password
                                        VStack(spacing: 0) {
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
                                                
                                                // 自定义分隔线
                                                Rectangle()
                                                        .fill(Color(red: 243/255, green: 244/255, blue: 247/255))
                                                        .frame(height: 12)
                                        }
                                        
                                        // Current Version
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
                                                
                                                Divider()
                                                        .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                        .padding(.horizontal, 22)
                                        }
                                        
                                        // Share This App
                                        VStack(spacing: 0) {
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
                                                        autoCloseDuration = value
                                                        let success = SdkUtil.shared.setAutoCloseDuration(value) // 保存用户选择的值
                                                        if !success {
                                                                SdkUtil.shared.toastManager?.showToast(message: "Save Failed!", isSuccess: false)
                                                        } else {
                                                                SdkUtil.shared.toastManager?.showToast(message: "Save Success!", isSuccess: true)
                                                        }
                                                        show = false
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
}
