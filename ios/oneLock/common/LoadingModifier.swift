//
//  LoadingModifier.swift
//  oneLock
//
//  Created by wesley on 2025/1/2.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
        @ObservedObject private var loadingManager = LoadingManager.shared // 使用全局单例
        
        func body(content: Content) -> some View {
                ZStack {
                        content // 原始视图
                        
                        if loadingManager.isVisible {
                                ZStack {
                                        Color.black.opacity(0.4)
                                                .edgesIgnoringSafeArea(.all)
                                        
                                        VStack(spacing: 20) {
                                                ProgressView()
                                                        .scaleEffect(1.5)
                                                Text(loadingManager.message)
                                                        .font(.headline)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .background(Color.black.opacity(0.7))
                                                        .cornerRadius(10)
                                        }
                                        .padding()
                                }
                                .transition(AnyTransition.opacity.combined(with: .scale))
                                .animation(.easeInOut, value: loadingManager.isVisible)
                        }
                }
        }
}

extension View {
        func loadingView() -> some View {
                self.modifier(LoadingModifier())
        }
}
