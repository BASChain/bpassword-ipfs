//
//  NewAuthAccountView.swift
//  oneLock
//
//  Created by wesley on 2025/1/11.
//


import SwiftUI

struct NewAuthAccountView: View {
        @State private var service: String = ""
        @State private var account: String = ""
        @State private var key: String = ""
        
        var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                        Group {
                                Text("SERVICE")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                
                                TextField("ex:Onelock", text: $service)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                
                                Text("ACCOUNT")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                
                                TextField("ex:11111…111", text: $account)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                                
                                Text("KEY")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                
                                TextField("ex:oooooo", text: $key)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                                print("Save tapped with service: \(service), account: \(account), key: \(key)")
                        }) {
                                Text("Save")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cyan)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                        }
                }
                .padding(.top, 20)
                .navigationBarTitle("Add Account", displayMode: .inline)
        }
}
