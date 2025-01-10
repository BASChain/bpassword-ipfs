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
                        Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                        dismiss()
                                }
                        
                        VStack(spacing: 20) {
                                Image(isSuccess ? "success-icon" : "oops-icon")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                
                                Text(title)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                
                                Text(message)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding(40)
                }
        }
        
        private func dismiss() {
                presentationMode.wrappedValue.dismiss()
                onDismiss?()
        }
}
