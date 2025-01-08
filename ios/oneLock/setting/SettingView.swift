import SwiftUI

struct SettingView: View {
    @State private var autoCloseDuration: Int = SdkUtil.shared.getAutoCloseDuration()
    let blockchainAddress: String = SdkUtil.shared.walletAddress()
    
    var body: some View {
        NavigationView {
            List {
                // MARK: 1) 区块链地址
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
                    // 根据设计图可微调上下左右间距
                    .padding(.top, 22)
                    .padding(.leading, 22)
                    .padding(.bottom, 34)
                    .padding(.trailing, 22)
                }
                // 去掉默认内边距与行背景，让自定义背景能完整展示
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                // 给整行左右留白22pt，贴合设计图
                .padding(.horizontal, 22)
                // 保持与设计图同样高度
                .frame(height: 105)
                
                // MARK: 2) Auto Close Wallet Duration
                HStack {
                    Text("Auto Close Wallet Duration")
                        .font(.custom("SFProText-Medium", size: 15))
                        .foregroundColor(.black)
                    Spacer()
                    Picker("", selection: $autoCloseDuration) {
                        ForEach([1, 5, 10, 15, 30, 60], id: \.self) { value in
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
                
                // MARK: 3) Change Password
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
                
                // MARK: 4) 自定义分隔线（若设计图有一个灰色线条）
                Rectangle()
                    .fill(Color(red: 243/255, green: 244/255, blue: 247/255))
                    .frame(height: 1)
                    // 上下留些间距以便与两行内容分隔开
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                
                // MARK: 5) Current Version
                HStack {
                    Text("Current Version")
                        .font(.custom("SFProText-Medium", size: 15))
                        .foregroundColor(.black)
                    Spacer()
                    Text(SdkUtil.shared.getVersion()) // 例: "1.0"
                        .font(.custom("SFProText-Regular", size: 14))
                        .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                        .cornerRadius(10)
                }
                
                // MARK: 6) Share This App
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
            }
            // 让列表平整无分组间距
            .listStyle(PlainListStyle())
            // 导航标题
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
