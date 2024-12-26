//
//  LoadingView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//


import SwiftUI

struct LoadingView: View {
    @Binding var isVisible: Bool
    @Binding var message: String

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.4) // 半透明背景
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    ProgressView() // 系统加载动画
                        .scaleEffect(1.5)
                    Text(message) // 提示内容
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
