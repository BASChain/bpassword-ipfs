import SwiftUI

struct GenericAlertView: View {
        @Binding var isPresented: Bool
        let title: String
        let message: String
        let onConfirm: () -> Void
        let onCancel: () -> Void
        
        var body: some View {
                if isPresented {
                        ZStack {
                                // 半透明背景遮罩
                                Color.black.opacity(0.4)
                                        .edgesIgnoringSafeArea(.all)
                                        .onTapGesture {
                                                // 点击背景关闭弹窗
                                                onCancel()
                                                isPresented = false
                                        }
                                
                                VStack(spacing: 20) {
                                        // 标题
                                        Text(title)
                                                .font(.custom("HelveticaNeue-Bold", size: 18))
                                                .foregroundColor(Color(red: 25/255, green: 25/255, blue: 29/255))
                                                .multilineTextAlignment(.center)
                                        
                                        // 消息内容
                                        Text(message)
                                                .font(.custom("HelveticaNeue", size: 14))
                                                .foregroundColor(Color(red: 103/255, green: 103/255, blue: 106/255))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 20)
                                        
                                        // 按钮区域
                                        HStack(spacing: 16) {
                                                // 取消按钮
                                                Button(action: {
                                                        onCancel()
                                                        isPresented = false
                                                }) {
                                                        Text("Cancel")
                                                                .font(.custom("PingFangSC-Semibold", size: 16))
                                                                .foregroundColor(Color(red: 41/255, green: 97/255, blue: 97/255))
                                                                .padding(.vertical, 11)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                                                .cornerRadius(31)
                                                }
                                                
                                                // 确认按钮
                                                Button(action: {
                                                        onConfirm()
                                                        isPresented = false
                                                }) {
                                                        Text("Confirm")
                                                                .font(.custom("PingFangSC-Semibold", size: 16))
                                                                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 54/255))
                                                                .padding(.vertical, 11)
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color(red: 255/255, green: 161/255, blue: 54/255))
                                                                .cornerRadius(31)
                                                }
                                        }
                                        .padding(.horizontal, 16)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal, 40) // 修正此处的 padding 确保两侧有10pt距离
                        }
                }
        }
}

extension View {
        func showAlert(
                isPresented: Binding<Bool>,
                title: String,
                message: String,
                onConfirm: @escaping () -> Void,
                onCancel: @escaping () -> Void
        ) -> some View {
                self.overlay(
                        GenericAlertView(
                                isPresented: isPresented,
                                title: title,
                                message: message,
                                onConfirm: onConfirm,
                                onCancel: onCancel
                        )
                )
        }
}
