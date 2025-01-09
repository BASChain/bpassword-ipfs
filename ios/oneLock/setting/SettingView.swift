import SwiftUI

struct SettingView: View {
        @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
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
                                                        
                                                        Text(blockchainAddress)
                                                                .font(.custom("Helvetica", size: 14))
                                                                .foregroundColor(.white)
                                                                .lineLimit(1)
                                                                .truncationMode(.middle)
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
                                                        Picker("", selection: $autoCloseDuration) {
                                                                ForEach([1, 5, 10, 15, 30, 60], id: \ .self) { value in
                                                                        Text("\(value) Mins")
                                                                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                                                .tag(value)
                                                                }
                                                        }
                                                        .pickerStyle(.menu)
                                                        .onChange(of: autoCloseDuration) { newValue in
                                                                let success = SdkUtil.shared.setAutoCloseDuration(newValue)
                                                                if !success {
                                                                        SdkUtil.shared.toastManager?.showToast(message: "Save Failed!", isSuccess: false)
                                                                } else {
                                                                        SdkUtil.shared.toastManager?.showToast(message: "Save Success!", isSuccess: true)
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
                                                                Image(systemName: "lock")
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
                                                        .frame(height: 8)
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
                                                                Image(systemName: "square.and.arrow.up")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 11, height: 13)
                                                                        .foregroundColor(.blue)
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
        }
        
        private func shareApp() {
                guard let url = URL(string: SdkUtil.AppUrl) else { return }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(activityVC, animated: true, completion: nil)
                } else {
                        print("Unable to present activity view controller")
                }
        }
}

// MARK: - 预览
struct SettingView_Previews: PreviewProvider {
        static var previews: some View {
                SettingView()
        }
}
