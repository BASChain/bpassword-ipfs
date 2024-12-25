//
//  SdkUtil.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import Foundation
import OneKeyLib

enum LogLevel: Int8 {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
}

// 定义一个类以实现日志处理
class SdkUtil: NSObject {
        // MARK: - 单例模式
        static let shared = SdkUtil()
        
        private override init() {
                super.init()
        }
        
        // MARK: - 方法
        func initializeSDK(logLevel: LogLevel) {
                // 调用 Go 库中的 InitSDK 方法
                
                var err:NSError? = nil
                OneKeyLibInitSDK(self, logLevel.rawValue, &err)
                
                if let error = err {
                        print("Failed to initialize SDK: \(error.localizedDescription)")
                }
        }
}

// MARK: - 实现 Go 的 APPI 接口
extension SdkUtil: OneKeyLibAPPIProtocol {
        func log(_ s: String?) {
                // 处理从 Go 库传回的日志
                print("[GoSDK] \(s ?? "")")
        }
}
