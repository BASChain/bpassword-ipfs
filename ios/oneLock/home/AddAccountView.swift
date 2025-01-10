import SwiftUI

struct AddAccountView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var platform: String = ""
        @State private var username: String = ""
        @State private var password: String = ""
        @State private var isPasswordVisible: Bool = false
        
        var onSave: (() -> Void)? // 回调通知 HomeView 刷新
        
        var body: some View {
                VStack(spacing: 16) {
                        // 表单区域
                        VStack(alignment: .leading, spacing: 24) {
                                // 平台输入
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("PLATFORM")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                        
                                        TextField("Enter platform name", text: $platform)
                                                .padding() .autocapitalization(.none) // 禁止首字母大写
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                }
                                
                                // 用户名输入
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("USERNAME")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                        
                                        TextField("Enter username", text: $username)
                                                .padding() .autocapitalization(.none) // 禁止首字母大写
                                                .background(Color(red: 243/255, green: 243/255, blue: 243/255))
                                                .cornerRadius(31)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                }
                                
                                // 密码输入
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("PASSWORD")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                        
                                        HStack {
                                                if isPasswordVisible {
                                                        TextField("Enter password", text: $password)
                                                                .padding() .autocapitalization(.none) // 禁止首字母大写
                                                                .background(Color(red: 203/255, green: 233/255, blue: 232/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                } else {
                                                        SecureField("Enter password", text: $password)
                                                                .padding() .autocapitalization(.none) // 禁止首字母大写
                                                                .background(Color(red: 203/255, green: 233/255, blue: 232/255))
                                                                .cornerRadius(31)
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                }
                                                
                                                Button(action: {
                                                        isPasswordVisible.toggle()
                                                }) {
                                                        Image(isPasswordVisible ? "opened-icon" : "closed-icon")
                                                                .foregroundColor(Color(red: 113/255, green: 157/255, blue: 157/255))
                                                }
                                        }
                                }
                                
                                // 保存按钮
                                Button(action: saveAccount) {
                                        Text("Save")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                .cornerRadius(31)
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                }
                .background(Color.white)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                        ToolbarItem(placement: .principal) {
                                Text("Add Account")
                                        .font(.custom("SFProText-Medium", size: 18))
                                        .foregroundColor(Color.black)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                }) {
                                        Image("back_icon") // 替换为实际的返回图标
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                }
                        }
                }
                .onTapGesture {
                        // 点击空白区域时隐藏键盘
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        }
        
        private func saveAccount() {
                guard !platform.isEmpty, !username.isEmpty, !password.isEmpty else {
                        PopupManager.shared.showPopup(title: "Tips", message: "All fields are required", isSuccess: false)
                        return
                }
                let account = Account(platform: platform, username: username,
                                      password: password, lastUpdated: Int64(Date().timeIntervalSince1970))
                LoadingManager.shared.show(message: "Saving Account...")
                
                DispatchQueue.global().async {
                        do {  let success = try SdkUtil.shared.addAccount(account: account)
                                
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        if success {
                                                onSave?() // 通知 HomeView 刷新
                                                presentationMode.wrappedValue.dismiss()
                                        } else {
                                                print("Failed to save account")
                                                SdkUtil.shared.toastManager?.showToast(message: "Operation failed", isSuccess: false)
                                        }
                                }
                        } catch {
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        print("Error saving account: \(error.localizedDescription)")
                                        SdkUtil.shared.toastManager?.showToast(message: "An error occurred: \(error.localizedDescription)", isSuccess: false)
                                }
                        }
                }
        }
}
