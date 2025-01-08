import SwiftUI

struct AccountDetailView: View {
        @Binding var account: Account // 使用 @Binding 从父视图传递进来
        @State private var isPasswordVisible: Bool = false
        @State private var showAlert: Bool = false
        @State private var showEditView: Bool = false // 控制跳转到编辑界面
        @Environment(\.presentationMode) var presentationMode
        var onAccountDeleted: (() -> Void)?
        
        var body: some View {
                ZStack {
                        VStack(spacing: 20) {
                                // 信息区域
                                VStack(spacing: 16) {
                                        InfoRow(title: "Platform", value: account.platform)
                                        Divider().background(Color.gray.opacity(0.3))
                                        
                                        InfoRow(title: "Username", value: account.username)
                                        Divider().background(Color.gray.opacity(0.3))
                                        
                                        InfoRow(title: "Password", value: isPasswordVisible ? account.password : "Password Hidden")
                                }
                                .padding()
                                .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                .cornerRadius(22)
                                .padding(.horizontal, 12)
                                
                                // 提示文字
                                Button(action: {}) {
                                        Text("Press and Hold to View Password!")
                                                .font(.custom("PingFangSC-Medium", size: 16))
                                                .foregroundColor(Color.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                .cornerRadius(22)
                                }
                                .padding(.horizontal, 28)
                                .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                        withAnimation {
                                                isPasswordVisible = isPressing
                                        }
                                }) {}
                                
                                // 编辑按钮
                                Button(action: {
                                        showEditView = true
                                }) {
                                        Text("Edit Account")
                                                .font(.custom("PingFangSC-Medium", size: 16))
                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(red: 255/255, green: 161/255, blue: 54/255))
                                                .cornerRadius(22)
                                }
                                .padding(.horizontal, 28)
                                
                                Spacer()
                        }
                        .padding()
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                                ToolbarItem(placement: .principal) {
                                        Text("Account Details")
                                                .font(.custom("SFProText-Medium", size: 18))
                                                .foregroundColor(Color.black)
                                }
                                ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: {
                                                presentationMode.wrappedValue.dismiss()
                                        }) {
                                                Image("back_icon")
                                                        .resizable()
                                                        .frame(width: 13, height: 13)
                                        }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                                showAlert = true
                                        }) {
                                                Image("dle_icon")
                                                        .resizable()
                                                        .frame(width: 18, height: 18)
                                        }
                                }
                        }
                        
                        // 删除确认弹窗
                        GenericAlertView(
                                isPresented: $showAlert,
                                title: "Confirm Deletion",
                                message: "Are you sure you want to delete this account?",
                                onConfirm: deleteAccount,
                                onCancel: {
                                        showAlert = false
                                }
                        )
                }
                .sheet(isPresented: $showEditView) {
                        EditAccountView(account: account) { updatedAccount in
                                account = updatedAccount
                        }
                }
        }
        
        private func deleteAccount() {
                showAlert = false
                LoadingManager.shared.show(message: "Deleting Account...")
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.removeAccount(uuid: account.id)
                        DispatchQueue.main.async {
                                LoadingManager.shared.hide()
                                if success {
                                        onAccountDeleted?()
                                        presentationMode.wrappedValue.dismiss()
                                } else {
                                        print("Failed to delete account")
                                }
                        }
                }
        }
}

struct InfoRow: View {
        let title: String
        let value: String
        
        var body: some View {
                HStack {
                        Text(title)
                                .font(.custom("PingFangSC-Regular", size: 14))
                                .foregroundColor(Color.gray)
                        Spacer()
                        ZStack {
                                if value == "Password Hidden" {
                                        Image("password_mask")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 30)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .overlay(
                                                        Text(value)
                                                                .font(.custom("SFProText-Medium", size: 16))
                                                                .foregroundColor(.gray)
                                                )
                                } else {
                                        Text(value)
                                                .font(.custom("SFProText-Medium", size: 16))
                                                .foregroundColor(.black)
                                }
                        }
                }
                .padding(.horizontal, 24)
        }
}
