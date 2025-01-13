import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
                GeometryReader { geometry in
                        ZStack {
                                Color.blue
                                        .ignoresSafeArea()
                                
                                VStack(spacing: 0) {
                                        // 顶部红色背景
                                        Color.red
                                                .frame(height: max((UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows.first }.first?.safeAreaInsets.top ?? 0) + 60, 80)) // 限制最小高度为 80
                                                .ignoresSafeArea(edges: .top)
                                                .border(Color.black, width: 2) // 调试边框
                                        
                                        // 黄色输入框和按钮区域
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
                                        .background(Color.yellow)
                                        .border(Color.black, width: 2) // 调试边框
                                        
                                        Spacer() // 保持黄色内容下方留白
                                }
                                .border(Color.green, width: 2) // 调试整体 VStack 边框
                        }
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
        }
}
