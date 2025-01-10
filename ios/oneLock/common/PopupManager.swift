import SwiftUI

class PopupManager {
        static let shared = PopupManager()
        private init() {}
        
        func showPopup(title: String, message: String, isSuccess: Bool, onDismiss: (() -> Void)? = nil) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                        return
                }
                
                let popupView = PopupView(title: title, message: message, isSuccess: isSuccess, onDismiss: onDismiss)
                
                let hostingController = UIHostingController(rootView: popupView)
                hostingController.modalPresentationStyle = .overFullScreen
                hostingController.view.backgroundColor = .clear
                
                keyWindow.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
}

struct PopupView: View {
        let title: String
        let message: String
        let isSuccess: Bool
        var onDismiss: (() -> Void)?
        
        @Environment(\.presentationMode) private var presentationMode
        
        var body: some View {
                ZStack {
                        // 背景遮罩
                        Color.black.opacity(0.6)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                        dismiss()
                                }
                        
                        // 弹框内容
                        VStack(spacing: 16) { // 调整间距
                                Image(isSuccess ? "success-icon" : "oops-icon")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15) // 图标动态大小
                                
                                Text(title)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                
                                Text(message)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(width: UIScreen.main.bounds.width * 0.8) // 动态宽度
                        .background(Color.white)
                        .cornerRadius(16) // 圆角更大
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4) // 细腻阴影
                }
        }
        
        private func dismiss() {
                presentationMode.wrappedValue.dismiss()
                onDismiss?()
        }
}
