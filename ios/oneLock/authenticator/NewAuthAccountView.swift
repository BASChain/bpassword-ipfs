import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        @Environment(\.presentationMode) var presentationMode
        @State private var showAlert: Bool = false
        
        var body: some View {
                VStack(alignment: .leading, spacing: 23) {
                        // Service Field
                        VStack(alignment: .leading, spacing: 8) {
                                Text("SERVICE")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                
                                TextField("ex:Onelock", text: $service)
                                        .padding()
                                        .background(Color(red: 243 / 255, green: 249 / 255, blue: 250 / 255))
                                        .cornerRadius(10)
                        }
                        .padding(.horizontal).padding(.top, -15)
                        
                        // Account Field
                        VStack(alignment: .leading, spacing: 8) {
                                Text("ACCOUNT")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                
                                TextField("ex:11111…111", text: $account)
                                        .padding()
                                        .background(Color(red: 243 / 255, green: 249 / 255, blue: 250 / 255))
                                        .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Key Field
                        VStack(alignment: .leading, spacing: 8) {
                                Text("KEY")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255))
                                
                                TextField("ex:oooooo", text: $key)
                                        .padding()
                                        .background(Color(red: 243 / 255, green: 249 / 255, blue: 250 / 255))
                                        .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Save Button
                        Button(action: {
                                print("Save tapped with service: \(service), account: \(account), key: \(key)")
                        }) {
                                Text("Save")
                                        .font(.system(size: 16, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 0 / 255, green: 188 / 255, blue: 212 / 255))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                        }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(content: {
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
                                                .frame(width: 24, height: 24)
                                }
                        }
                })
        }
}
