import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        
        var onSave: (() -> Void)? // 回调通知 HomeView 刷新
        
        var body: some View {
                ZStack {
                        // 主要内容容器
                        VStack(spacing: 0) {
                                // Service Field Group
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("SERVICE")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                                .padding(.horizontal, 20)
                                        
                                        TextField("Enter service name (e.g., Onelock)", text: $service)
                                                .padding()
                                                .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                .cornerRadius(32)
                                                .padding(.horizontal, 20)
                                                .frame(height: 46)
                                                .onChange(of: service) { newValue in
                                                        if newValue.count > 30 {
                                                                service = String(newValue.prefix(30))
                                                        }
                                                }
                                }
                                .padding(.top, 120)
                                
                                // Account Field Group
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("ACCOUNT")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                                .padding(.horizontal, 20)
                                        
                                        TextField("ex:11111…111", text: $account)
                                                .padding()
                                                .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                .cornerRadius(32)
                                                .padding(.horizontal, 20)
                                                .frame(height: 46)
                                                .onChange(of: account) { newValue in
                                                        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@.-_"))
                                                        account = newValue.filter { String($0).rangeOfCharacter(from: validCharacters) != nil }
                                                }
                                }
                                .padding(.top, 12)
                                
                                // Key Field Group
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("KEY")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                                .padding(.horizontal, 20)
                                        
                                        TextField("ex:oooooo", text: $key)
                                                .padding()
                                                .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                .cornerRadius(32)
                                                .padding(.horizontal, 20)
                                                .frame(height: 46)
                                                .onChange(of: key) { newValue in
                                                        let validCharacters = CharacterSet.alphanumerics
                                                        key = newValue.filter { String($0).rangeOfCharacter(from: validCharacters) != nil }
                                                }
                                }
                                .padding(.top, 12)
                                
                                // Save 按钮
                                Button(action: {
                                        saveNewAuth()
                                }) {
                                        Text("Save")
                                                .font(.system(size: 19, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 46)
                                                .background(Color(red: 15 / 255, green: 211 / 255, blue: 212 / 255))
                                                .foregroundColor(.white)
                                                .cornerRadius(32)
                                                .padding(.horizontal, 20)
                                }
                                .padding(.top, 24)
                                
                                Spacer() // 保持内容与底部的间距
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea() // 忽略安全区域，使边框覆盖到导航栏
                .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(content: {
                        ToolbarItem(placement: .principal) {
                                Text("Add Account")
                                        .font(.custom("SFProText-Medium", size: 18))
                                        .foregroundColor(Color.black)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                }) {
                                        Image("back_icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                }
                        }
                })
        }
        
        private func saveNewAuth(){
                
                guard !service.isEmpty, !account.isEmpty, !key.isEmpty else {
                        PopupManager.shared.showPopup(title: "Tips", message: "All fields are required", isSuccess: false)
                        return
                }
                LoadingManager.shared.show(message: "Saving Account...")
                
                DispatchQueue.global().async {
                        do {
                                let success = try SdkUtil.shared.NewAuthManual(issuer: service, account: account, secret: key)
                                
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        if success {
                                                onSave?() 
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
