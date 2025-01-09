//
//  LoadingModifier.swift
//  oneLock
//
//  Created by wesley on 2025/1/2.
//

import SwiftUI

class LoadingManager: ObservableObject {
        @Published var isVisible: Bool = false
        @Published var message: String = ""
        
        static let shared = LoadingManager() // 单例模式
        
        private init() {}
        
        func show(message: String) {
                DispatchQueue.main.async {
                        self.message = message
                        self.isVisible = true
                }
        }
        
        func hide() {
                DispatchQueue.main.async {
                        self.isVisible = false
                }
        }
}

struct LoadingModifier: ViewModifier {
        @ObservedObject private var loadingManager = LoadingManager.shared // 使用全局单例
        @State private var rotationAngle: Double = 0 // 控制旋转角度
        
        func body(content: Content) -> some View {
                ZStack {
                        content // 原始视图
                        
                        if loadingManager.isVisible {
                                ZStack {
                                        Color.black.opacity(0.4)
                                                .edgesIgnoringSafeArea(.all)
                                        
                                        VStack(spacing: 20) {
                                                Image("loading")
                                                        .resizable()
                                                        .frame(width: 50, height: 50)
                                                        .rotationEffect(Angle(degrees: rotationAngle))
                                                        .onAppear {
                                                                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                                                        rotationAngle = 360
                                                                }
                                                        }
                                                
                                                Text(loadingManager.message)
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.black)
                                                        .padding()
                                                        .background(Color.white)
                                                        .cornerRadius(8)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
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
