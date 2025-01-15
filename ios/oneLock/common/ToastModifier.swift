import SwiftUI

class ToastManager: ObservableObject {
        @Published var isVisible: Bool = false  // 是否显示 Toast
        @Published var message: String = ""    // Toast 提示信息
        @Published var isSuccess: Bool = true  // Toast 状态（成功/失败）
        @Published var duration: Double = 3.0  // 默认显示时长
        
        func showToast(message: String, isSuccess: Bool, duration: Double = 3.0) {
                
                DispatchQueue.main.async {
                        self.message = message
                        self.isSuccess = isSuccess
                        self.duration = duration
                        self.isVisible = true
                }
                
                // 自动隐藏
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.isVisible = false
                }
        }
}

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
                                .background(isSuccess ? Color(red: 30/255, green: 213/255, blue: 213/255) : Color(red: 255/255, green: 110/255, blue: 54/255))
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
