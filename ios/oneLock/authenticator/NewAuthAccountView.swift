import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
                GeometryReader { geometry in
                        VStack(spacing: 0) {
                                // 顶部红色背景覆盖导航栏和动态岛区域
                                Color.red
                                        .frame(height: (UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows.first }.first?.safeAreaInsets.top ?? 0) + 80) // 动态岛额外补偿高度
                                        .ignoresSafeArea(edges: .top)
                                
                                // 输入框和按钮内容
                                VStack(spacing: 16) {
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
                                        
                                        // Save 按钮
                                        Button(action: {
                                                print("Save tapped with service: \(service), account: \(account), key: \(key)")
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
                                }
                                .padding(.top, 0) // 确保黄色区域紧贴红色背景底部
                                .background(Color.yellow) // 设置背景颜色为黄色
                                .frame(maxWidth: .infinity, alignment: .top) // 对齐顶部
                                
                                Spacer() // 防止内容挤压
                        }
                        .background(Color.blue.ignoresSafeArea()) // 蓝色背景作为底层背景
                        .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .frame(maxHeight: .infinity, alignment: .top) // 让 VStack 占满空间并对齐顶部
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
        }
}
