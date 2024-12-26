//
//  AddAccountView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//
import SwiftUI


struct AddAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var platform: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false // 控制密码可见性

    var body: some View {
        Form {
            Section(header: Text("Platform")) {
                TextField("Enter platform name", text: $platform)
            }
            Section(header: Text("Username")) {
                TextField("Enter username", text: $username)
            }
            Section(header: Text("Password")) {
                HStack {
                    if isPasswordVisible {
                        TextField("Enter password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Enter password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button(action: {
                        isPasswordVisible.toggle() // 切换密码可见性
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
            }
            Button("Save") {
                // 保存逻辑
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Add Account")
    }
}
