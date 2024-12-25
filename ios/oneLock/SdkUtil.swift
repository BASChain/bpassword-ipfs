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
        
        private func getDatabasePath() -> String {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDirectory = paths[0]
                return documentDirectory.appendingPathComponent("oneLockDb").path
        }
        
        // MARK: - 方法
        func initializeSDK(logLevel: LogLevel) {
                // 调用 Go 库中的 InitSDK 方法
                let dbPath = getDatabasePath()
                var err:NSError? = nil
                OneKeyLibInitSDK(self, dbPath, logLevel.rawValue, &err)
                
                if let error = err {
                        print("Failed to initialize SDK: \(error.localizedDescription)")
                }
        }
        
        func checkWallet() -> String? {
                
                // 调用 Go 的 CheckWallet 方法
                var err:NSError? = nil
                if let walletData =  OneKeyLibCheckWallet(&err) {
                        if let walletString = String(data: walletData as Data, encoding: .utf8) {
                                return walletString
                        } else {
                                print("Failed to decode wallet data.")
                        }
                }
                if let error = err {
                        print("Error checking wallet: \(error.localizedDescription)")
                }
                return nil
        }
        
        func generateMnemonic(password: String) -> String? {
                var err: NSError? = nil
                
                // 调用 Go 侧 API 生成助记词数据
                guard let mnemonicData = OneKeyLibGenerateMnemonic(&err) else {
                        print("Error generating mnemonic: \(err?.localizedDescription ?? "Unknown error").")
                        return nil
                }
                
                // 将助记词数据解码为字符串
                guard let mnemonicString = String(data: mnemonicData as Data, encoding: .utf8) else {
                        print("Failed to decode mnemonic data.")
                        return nil
                }
                
                return mnemonicString
        }
        
        func createWallet(mnemonic: String,password:String)->Bool {
                var err: NSError? = nil
                OneKeyLibGenerateWallet(mnemonic,password, &err)
                guard let e = err else{
                        return true
                }
                print("Failed to create wallet\(e.localizedDescription).")
                return false
        }
}

// MARK: - 实现 Go 的 APPI 接口
extension SdkUtil: OneKeyLibAPPIProtocol {
        func log(_ s: String?) {
                // 处理从 Go 库传回的日志
                print("[GoSDK] \(s ?? "")")
        }
}
