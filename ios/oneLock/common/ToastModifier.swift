import SwiftUI

struct ToastModifier: ViewModifier {
        @Binding var isVisible: Bool
        let message: String
        let isSuccess: Bool
        let duration: Double // Toast 显示时长（秒）
        
        func body(content: Content) -> some View {
                ZStack {
                        content // 原始视图内容
                        
                        if isVisible {
                                HStack {
                                        Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        
                                        Text(message)
                                                .font(.body)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(isSuccess ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .transition(AnyTransition.opacity.combined(with: .scale))
                                .onAppear {
                                        // 自动隐藏 Toast
                                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                                withAnimation {
                                                        self.isVisible = false
                                                }
                                        }
                                }
                        }
                }
        }
}

extension View {
        func toast(isVisible: Binding<Bool>, message: String, isSuccess: Bool, duration: Double = 3.0) -> some View {
                self.modifier(ToastModifier(isVisible: isVisible, message: message, isSuccess: isSuccess, duration: duration))
        }
}
