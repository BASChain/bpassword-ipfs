import SwiftUI
import AVFoundation

struct AuthScanView: View {
        @State private var isScanning: Bool = true  // 自动开始扫描
        @State private var scannedCode: String? = nil
        @Environment(\.presentationMode) var presentationMode
        
        var onScanComplete: ((String?) -> Void)?
        
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
                                                                        .onAppear {
                                                                                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                                                                                        scannedCode = nil
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
                        }
                }
                .onAppear {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onDisappear {
                        if let code = scannedCode {
                                onScanComplete?(code)
                        } else {
                                onScanComplete?(nil)
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
                        print("Scanned code: \(code)")
                        DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                        }
                case .failure:
                        SdkUtil.shared.toastManager?.showToast(message: "Scan failed", isSuccess: false)
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
                        print("Delegate didFindCode called with code: \(code)") // 打印详细信息
                        completion(.success(code))
                }
                
                func didFailWithError(_ error: Error) {
                        print("Delegate didFailWithError called with error: \(error.localizedDescription)") // 打印详细错误信息
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
                
                print("ScannerViewController viewDidLoad called")
                
                let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
                switch cameraAuthorizationStatus {
                case .notDetermined:
                        AVCaptureDevice.requestAccess(for: .video) { granted in
                                if granted {
                                        DispatchQueue.main.async {
                                                self.setupCaptureSession()
                                        }
                                } else {
                                        print("Camera access denied")
                                }
                        }
                case .authorized:
                        print("Camera access authorized")
                        DispatchQueue.global(qos: .background).async {
                                self.setupCaptureSession()
                        }
                case .restricted, .denied:
                        print("Camera access restricted or denied")
                        return
                @unknown default:
                        fatalError("Unknown camera authorization status")
                }
        }
        
        func setupCaptureSession() {
                captureSession = AVCaptureSession()
                
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                        print("No video capture device found")
                        return
                }
                let videoInput: AVCaptureDeviceInput
                
                do {
                        videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                        print("Video input successfully created")
                } catch {
                        print("Error creating video input: \(error.localizedDescription)")
                        delegate?.didFailWithError(error)
                        return
                }
                
                if captureSession.canAddInput(videoInput) {
                        captureSession.addInput(videoInput)
                        print("Video input added to capture session")
                } else {
                        print("Unable to add video input to capture session")
                        delegate?.didFailWithError(CodeScannerView.ScanError.unknown)
                        return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                if captureSession.canAddOutput(metadataOutput) {
                        captureSession.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        print("Metadata output added and configured")
                } else {
                        print("Unable to add metadata output to capture session")
                        delegate?.didFailWithError(CodeScannerView.ScanError.unknown)
                        return
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                DispatchQueue.main.async {
                        previewLayer.frame = self.view.layer.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        print("Preview layer added")
                }
                
                DispatchQueue.global(qos: .background).async {
                        self.captureSession.startRunning()
                        print("Capture session started")
                }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                if captureSession.isRunning {
                        captureSession.stopRunning()
                        print("Capture session stopped")
                }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                print("Metadata output didOutput called with \(metadataObjects.count) objects")
                if let metadataObject = metadataObjects.first {
                        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                                print("Metadata object is not readable")
                                return
                        }
                        guard let stringValue = readableObject.stringValue else {
                                print("Metadata object has no string value")
                                return
                        }
                        print("Scanned value: \(stringValue)")
                        captureSession.stopRunning()
                        delegate?.didFindCode(stringValue)
                }
        }
}
