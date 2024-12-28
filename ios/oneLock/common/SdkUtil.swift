//
//  SdkUtil.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import Foundation
import LockLib

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
        //        private let server_url = "https://bc.simplenets.org:5001"
        private let server_url = "http://127.0.0.1:5002"
        private let server_token = "ac8ad031c9905e3ead2454d1a1f6c110"
        
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
                LockLibInitSDK(self, dbPath,server_url, server_token, logLevel.rawValue, &err)
                
                if let error = err {
                        print("Failed to initialize SDK: \(error.localizedDescription)")
                }
        }
        
        func checkWallet() -> String? {
                
                // 调用 Go 的 CheckWallet 方法
                var err:NSError? = nil
                if let walletData = LockLibCheckWallet(&err) {
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
        
        func generateMnemonic() -> String? {
                var err: NSError? = nil
                
                // 调用 Go 侧 API 生成助记词数据
                guard let mnemonicData = LockLibGenerateMnemonic(&err) else {
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
                LockLibGenerateWallet(mnemonic,password, &err)
                guard let e = err else{
                        return true
                }
                print("Failed to create wallet\(e.localizedDescription).")
                return false
        }
        
        func openWallet(password:String)->Bool{
                var err: NSError? = nil
                LockLibOpenWallet(password,&err)
                guard let e = err else{
                        return true
                }
                print("Failed to open wallet\(e.localizedDescription).")
                return false
        }
        
        func walletAddress()->String{
                return LockLibWalletAddress()
        }
        
        func addAccount(account: Account) -> Bool {
                var err: NSError? = nil
                
                // 将 Account 实例转换为 JSON 字符串
                guard let jsonStr = account.jsonString() else {
                        print("Failed to serialize Account to JSON.")
                        return false
                }
                
                // 调用 Go 的 OneKeyLibAddAccount 方法
                LockLibAddAccount(jsonStr, &err)
                
                // 检查错误
                guard let e = err else {
                        print("Account successfully saved.")
                        return true
                }
                
                // 打印详细错误信息
                print("Failed to save account. Error: \(e.localizedDescription)")
                print("Account JSON: \(jsonStr)")
                return false
        }
        
        func loadAccounts() -> [UUID: Account] {
                var accountsMap = [UUID: Account]()
                
                // 调用 Go 的 LoadAccountList 函数
                var err: NSError? = nil
                guard let jsonData = LockLibLoadAccountList(&err) else {
                        if let e = err {
                                print("Failed to load accounts: \(e.localizedDescription)")
                        }
                        return accountsMap
                }
                
                // 将返回的 JSON 数据解析为 [UUID: Account]
                do {
                        let decoder = JSONDecoder()
                        let decodedAccounts = try decoder.decode([String: Account].self, from: jsonData)
                        // 转换为 [UUID: Account] 格式
                        for (key, account) in decodedAccounts {
                                if let uuid = UUID(uuidString: key) {
                                        accountsMap[uuid] = account
                                }
                        }
                } catch {
                        print("Failed to decode accounts JSON: \(error.localizedDescription)")
                }
                
                return accountsMap
        }
        
        func removeAccount(uuid: UUID) -> Bool {
                var err: NSError? = nil
                LockLibRemoveAccount(uuid.uuidString, &err)
                
                if let e = err {
                        print("Failed to remove account: \(e.localizedDescription)")
                        return false
                }
                
                print("Account successfully removed: \(uuid.uuidString)")
                return true
        }
}

// MARK: - 实现 Go 的 APPI 接口
extension SdkUtil: LockLibAppIProtocol {
        @objc func log(_ s: String?) {
                // 处理从 Go 库传回的日志
                print("[GoSDK] \(s ?? "")")
        }
}
