import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        @State private var showAlert: Bool = false
        
        var body: some View {
                GeometryReader { geometry in
                        ZStack {
                                Color.green.contentShape(Rectangle()) .onTapGesture {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                VStack {
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
                                        .padding(.top, 24).background(Color.red)
                                        
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
                                                        .frame(height: 46)
                                                        .onChange(of: key) { newValue in
                                                                let validCharacters = CharacterSet.alphanumerics
                                                                key = newValue.filter { String($0).rangeOfCharacter(from: validCharacters) != nil }
                                                        }
                                        }
                                        .padding(.top, 6)
                                        
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
                                        .padding(.top, 24)
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
}
