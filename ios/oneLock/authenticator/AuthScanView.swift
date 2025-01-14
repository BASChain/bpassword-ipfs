import SwiftUI
import AVFoundation


struct AuthScanView: View {
        @State private var isScanning: Bool = true  // 自动开始扫描
        @State private var scannedCode: String? = nil
        @State private var scanLineOffset: CGFloat = -UIScreen.main.bounds.height * 0.3 // 初始偏移量
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
                ZStack {
                        Color.black.edgesIgnoringSafeArea(.all) // 背景颜色
                        
                        if isScanning {
                                CodeScannerView(codeTypes: [.qr], completion: handleScan)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .overlay(
                                                ZStack {
                                                        Color.black.opacity(0.5) // 半透明背景遮罩
                                                                .edgesIgnoringSafeArea(.all)
                                                        
                                                        VStack {
                                                                Spacer()
                                                                
                                                                // 扫描线区域
                                                                ZStack {
                                                                        LinearGradient(
                                                                                gradient: Gradient(colors: [
                                                                                        Color(red: 15/255, green: 211/255, blue: 212/255, opacity: 0),
                                                                                        Color(red: 15/255, green: 211/255, blue: 212/255, opacity: 0.76),
                                                                                        Color(red: 15/255, green: 211/255, blue: 212/255, opacity: 0)
                                                                                ]),
                                                                                startPoint: .top,
                                                                                endPoint: .bottom
                                                                        )
                                                                        .frame(height: 20)
                                                                        .offset(y: scanLineOffset)
                                                                        .onAppear {
                                                                                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                                                                                        scanLineOffset = UIScreen.main.bounds.height * 0.3
                                                                                }
                                                                        }
                                                                }
                                                                .padding(.horizontal, 26)
                                                                
                                                                Spacer()
                                                        }
                                                }
                                        )
                        } else {
                                Text(scannedCode ?? "Scan a QR Code")
                                        .font(.title)
                                        .padding()
                                
                                if let scannedCode = scannedCode {
                                        Button("Copy to Clipboard") {
                                                UIPasteboard.general.string = scannedCode
                                        }
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                        }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(content: {
                        ToolbarItem(placement: .principal) {
                                Text("Scan Account")
                                        .font(.custom("SFProText-Medium", size: 18))
                                        .foregroundColor(Color.white)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                }) {
                                        Image("scan-back-icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.white)
                                }
                        }
                })
        }
        
        func handleScan(result: Result<String, CodeScannerView.ScanError>) {
                isScanning = false
                switch result {
                case .success(let code):
                        scannedCode = code
                case .failure(let error):
                        print("Scanning failed: \(error.localizedDescription)")
                }
        }
}


struct CodeScannerView: UIViewControllerRepresentable {
        var codeTypes: [AVMetadataObject.ObjectType]
        var completion: (Result<String, ScanError>) -> Void
        
        func makeUIViewController(context: Context) -> ScannerViewController {
                let viewController = ScannerViewController()
                viewController.delegate = context.coordinator
                return viewController
        }
        
        func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
                Coordinator(completion: completion)
        }
        
        class Coordinator: NSObject, ScannerViewControllerDelegate {
                var completion: (Result<String, ScanError>) -> Void
                
                init(completion: @escaping (Result<String, ScanError>) -> Void) {
                        self.completion = completion
                }
                
                func didFindCode(_ code: String) {
                        completion(.success(code))
                }
                
                func didFailWithError(_ error: Error) {
                        completion(.failure(.unknown))
                }
        }
        
        enum ScanError: Error {
                case unknown
        }
}

protocol ScannerViewControllerDelegate: AnyObject {
        func didFindCode(_ code: String)
        func didFailWithError(_ error: Error)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        weak var delegate: ScannerViewControllerDelegate?
        var captureSession: AVCaptureSession!
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                captureSession = AVCaptureSession()
                
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
                let videoInput: AVCaptureDeviceInput
                
                do {
                        videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                        delegate?.didFailWithError(error)
                        return
                }
                
                if captureSession.canAddInput(videoInput) {
                        captureSession.addInput(videoInput)
                } else {
                        delegate?.didFailWithError(CodeScannerView.ScanError.unknown)
                        return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                if captureSession.canAddOutput(metadataOutput) {
                        captureSession.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        metadataOutput.rectOfInterest = CGRect(x: 0.2, y: 0.4, width: 0.6, height: 0.2)
                } else {
                        delegate?.didFailWithError(CodeScannerView.ScanError.unknown)
                        return
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = view.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer)
                
                let scanArea = UIView()
                scanArea.frame = CGRect(x: view.bounds.width * 0.2, y: view.bounds.height * 0.4, width: view.bounds.width * 0.6, height: view.bounds.height * 0.2)
                scanArea.layer.borderColor = UIColor.green.cgColor
                scanArea.layer.borderWidth = 2
                scanArea.backgroundColor = UIColor.clear
                view.addSubview(scanArea)
                
                captureSession.startRunning()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                if captureSession.isRunning {
                        captureSession.stopRunning()
                }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                if let metadataObject = metadataObjects.first {
                        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                        guard let stringValue = readableObject.stringValue else { return }
                        captureSession.stopRunning()
                        delegate?.didFindCode(stringValue)
                }
        }
}
