import SwiftUI

struct EditAccountView: View {
        @Binding var account: Account
        @State private var isPasswordVisible: Bool = false
        var onUpdate: (Account) -> Void
        @Binding var showEditView: Bool
        
        var body: some View {
                ZStack {
                        // 半透明背景
                        Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                        showEditView = false
                                }
                        
                        // 弹出视图
                        VStack(spacing: 16) {
                                // 标题栏
                                HStack {
                                        Spacer()
                                        Text("Edit Account")
                                                .font(.custom("SFProText-Medium", size: 18))
                                                .foregroundColor(Color.black)
                                        Spacer()
                                        Button(action: {
                                                showEditView = false
                                        }) {
                                                Image("close")
                                                        .resizable()
                                                        .frame(width: 18, height: 18)
                                                        .padding(.trailing, 16)
                                        }
                                }
                                .padding(.top, 16)
                                
                                // 输入区域
                                VStack(spacing: 16) {
                                        EditRow(title: "PLATFORM", text: $account.platform)
                                        EditRow(title: "USERNAME", text: $account.username)
                                        
                                        HStack {
                                                if isPasswordVisible {
                                                        TextField("PASSWORD", text: $account.password)
                                                                .textFieldStyle(PlainTextFieldStyle())
                                                } else {
                                                        SecureField("PASSWORD", text: $account.password)
                                                                .textFieldStyle(PlainTextFieldStyle())
                                                }
                                                Button(action: { isPasswordVisible.toggle() }) {
                                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                                                .foregroundColor(.gray)
                                                                .frame(width: 24, height: 24)
                                                }
                                        }
                                        .padding(12)
                                        .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                        .cornerRadius(22)
                                }
                                .padding(.horizontal, 24)
                                
                                // 更新按钮
                                Button(action: updateAccount) {
                                        Text("Update")
                                                .font(.custom("PingFangSC-Medium", size: 16))
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(red: 15/255, green: 211/255, blue: 212/255))
                                                .cornerRadius(22)
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                        }
                        .padding(.vertical, 16)
                        .frame(width: UIScreen.main.bounds.width)
                        .background(
                                ZStack {
                                        Color.white
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -2)
                                }
                        )
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
        }
        
        private func updateAccount() {
                account.lastUpdated = Int64(Date().timeIntervalSince1970)
                LoadingManager.shared.show(message: "Updating Account...")
                
                DispatchQueue.global().async {
                        do{
                                let success = try SdkUtil.shared.addAccount(account: self.account)
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        if success {
                                                onUpdate(account)
                                                showEditView = false
                                        } else {
                                                print("Failed to save account")
                                                SdkUtil.shared.toastManager?.showToast(message: "Operation failed", isSuccess: false)
                                        }
                                }
                                
                        }catch{
                                DispatchQueue.main.async {
                                        LoadingManager.shared.hide()
                                        print("Error saving account: \(error.localizedDescription)")
                                        SdkUtil.shared.toastManager?.showToast(message: "An error occurred: \(error.localizedDescription)", isSuccess: false)
                                }
                        }
                }
        }
}

struct EditRow: View {
        let title: String
        @Binding var text: String
        
        var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                                .font(.custom("PingFangSC-Medium", size: 14))
                                .foregroundColor(Color.gray)
                        
                        TextField("Enter \(title.lowercased())", text: $text)
                                .padding(12)
                                .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                .cornerRadius(22)
                }
        }
}

extension View {
        func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
                clipShape(RoundedCorner(radius: radius, corners: corners))
        }
}

struct RoundedCorner: Shape {
        var radius: CGFloat = 0.0
        var corners: UIRectCorner = .allCorners
        
        func path(in rect: CGRect) -> Path {
                let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
                return Path(path.cgPath)
        }
}
