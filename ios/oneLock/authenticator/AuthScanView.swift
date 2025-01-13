import SwiftUI
import AVFoundation

struct AuthScanView: View {
    @State private var isScanning: Bool = false
    @State private var scannedCode: String? = nil

    var body: some View {
        VStack {
            if isScanning {
                CodeScannerView(codeTypes: [.qr], completion: handleScan)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(scannedCode ?? "Scan a QR Code")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    self.isScanning = true
                }) {
                    Text("Start Scanning")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
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
        } else {
            delegate?.didFailWithError(CodeScannerView.ScanError.unknown)
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
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
