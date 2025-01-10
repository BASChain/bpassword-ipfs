import SwiftUI
import Network

class NetworkPermissionManager: ObservableObject {
        // 单例实例
        static let shared = NetworkPermissionManager()
        
        @Published var isPermissionGranted: Bool = false
        
        private var monitor: NWPathMonitor?
        private let queue = DispatchQueue(label: "NetworkMonitor")
        
        private init() { }  // 私有化初始化方法，确保不能通过其他方式初始化
        
        func requestPermission(completion: @escaping (Bool) -> Void) {
                // 模拟权限请求逻辑
                monitor = NWPathMonitor()
                monitor?.pathUpdateHandler = { path in
                        DispatchQueue.main.async {
                                if path.status == .satisfied {
                                        self.isPermissionGranted = true
                                        completion(true)
                                } else {
                                        self.isPermissionGranted = false
                                        completion(false)
                                }
                        }
                }
                monitor?.start(queue: queue)
        }
}

struct NetworkPermissionView: View {
        @StateObject private var permissionManager = NetworkPermissionManager.shared  // 使用单例实例
        @State private var showPermissionExplanation = false
        
        var body: some View {
                VStack {
                        Text("Welcome to the App!")
                                .font(.title)
                                .padding()
                        
                        Button("Access Online Features") {
                                // 展示说明
                                showPermissionExplanation = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showPermissionExplanation) {
                        Alert(
                                title: Text("Network Permission Required"),
                                message: Text("We need access to the internet to load online features and data."),
                                primaryButton: .default(Text("Allow")) {
                                        // 请求权限
                                        permissionManager.requestPermission { granted in
                                                if granted {
                                                        print("Permission granted")
                                                } else {
                                                        print("Permission denied")
                                                }
                                        }
                                },
                                secondaryButton: .cancel(Text("Deny"))
                        )
                }
        }
}
