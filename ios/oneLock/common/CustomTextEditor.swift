import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
        @Binding var text: String
        
        func makeUIView(context: Context) -> UITextView {
                let textView = UITextView()
                textView.isScrollEnabled = true
                textView.isEditable = true
                textView.isUserInteractionEnabled = true
                textView.font = UIFont.systemFont(ofSize: 16)
                textView.autocorrectionType = .no // 禁用预测文本
                textView.spellCheckingType = .no // 禁用拼写检查
                textView.smartQuotesType = .no // 禁用智能引号（可选）
                textView.smartDashesType = .no // 禁用智能破折号（可选）
                textView.smartInsertDeleteType = .no // 禁用智能插入和删除（可选）
                textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                textView.backgroundColor = UIColor(red: 203/255, green: 233/255, blue: 232/255, alpha: 1.0)
                textView.layer.cornerRadius = 31
                textView.layer.borderWidth = 2
                textView.layer.borderColor = UIColor(red: 203/255, green: 233/255, blue: 232/255, alpha: 1.0).cgColor
                textView.delegate = context.coordinator
                return textView
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
                uiView.text = text
        }
        
        func makeCoordinator() -> Coordinator {
                Coordinator(self)
        }
        
        class Coordinator: NSObject, UITextViewDelegate {
                var parent: CustomTextEditor
                
                init(_ parent: CustomTextEditor) {
                        self.parent = parent
                }
                
                func textViewDidChange(_ textView: UITextView) {
                        parent.text = textView.text
                }
        }
}
