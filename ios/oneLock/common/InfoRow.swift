//
//  InfoRow.swift
//  oneLock
//
//  Created by wesley on 2025/1/8.
//


import SwiftUI

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
