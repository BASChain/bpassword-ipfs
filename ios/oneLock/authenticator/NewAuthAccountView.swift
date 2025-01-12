import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        @State private var showAlert: Bool = false
        
        var body: some View {
                GeometryReader { geometry in
                        VStack {
                                // Service Field Group
                                VStack(alignment: .leading, spacing: 8) {
                                        Text("SERVICE")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                                .padding(.horizontal, 20)
                                        
                                        TextField("ex:Onelock", text: $service)
                                                .padding()
                                                .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
                                                .cornerRadius(32)
                                                .padding(.horizontal, 20)
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
                                }
                                .padding(.top, 6)
                                
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
                                }
                                .padding(.top, 6)
                                // Save 按钮
                                Button(action: {
                                        print("Save tapped with service: \(service), account: \(account), key: \(key)")
                                }) {
                                        Text("Save")
                                                .font(.system(size: 19, weight: .bold)) // 调整按钮字体大小和权重
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 46) // 增加按钮高度
                                                .background(Color(red: 15 / 255, green: 211 / 255, blue: 212 / 255))
                                                .foregroundColor(.white)
                                                .cornerRadius(32) // 增加按钮的圆角
                                                .padding(.horizontal, 20)
                                }
                                .padding(.top, 12)
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 24) // 增加底部间距
                        }.padding(.top, 60)
                                .navigationBarHidden(true)
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
                                .onTapGesture { // 点击非输入区域隐藏键盘
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                }
        }
}
