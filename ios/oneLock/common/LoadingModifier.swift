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
                                        
                                        VStack(spacing: 4) {
                                                Image("loading")
                                                        .resizable()
                                                        .frame(width: 60, height: 60)
                                                        .rotationEffect(Angle(degrees: rotationAngle))
                                                        .onAppear {
                                                                startRotation()
                                                        }
                                                        .onDisappear {
                                                                rotationAngle = 0 // 重置角度
                                                        }
                                                
                                                Text(loadingManager.message)
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(Color.black)
                                        }
                                        .padding(.vertical, 40)
                                        .padding(.horizontal, 50)
                                        .frame(maxWidth: UIScreen.main.bounds.width - 140)
                                        .frame(maxHeight: 140)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)
                                }
                                .transition(AnyTransition.opacity.combined(with: .scale))
                                .animation(.easeInOut, value: loadingManager.isVisible)
                                .onChange(of: loadingManager.isVisible) { isVisible in
                                        if isVisible {
                                                startRotation()
                                        } else {
                                                rotationAngle = 0 // 可选：在隐藏时重置角度
                                        }
                                }
                        }
                }
        }
        
        private func startRotation() {
                rotationAngle = 0
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                }
        }
}


extension View {
        func loadingView() -> some View {
                self.modifier(LoadingModifier())
        }
}
