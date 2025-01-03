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
        private let server_url = "https://bc.simplenets.org:5001"
        //        private let server_url = "http://192.168.18.51:5004"
        private let server_token = "ac8ad031c9905e3ead2454d1a1f6c110"
        static let AppUrl = "https://apps.apple.com/us/app/onelock/id6739830100"
        
        var toastManager: ToastManager? // 引用 ToastManager
        var appState: AppState?
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
                        syncLocalData()
                        return true
                }
                print("Failed to open wallet\(e.localizedDescription).")
                
                return false
        }
        
        func syncLocalData(){
                LockLibInitLocalData()
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
                
                LockLibAddOrUpdateAccount(jsonStr, &err)
                
                // 检查错误
                guard let e = err else {
                        print("Account successfully saved.")
                        return true
                }
                
                // 打印详细错误信息
                print("Failed to save account. Error: \(e.localizedDescription)")
                return false
        }
        
        func loadAccounts() -> [UUID: Account] {
                var accountsMap = [UUID: Account]()
                
                guard let jsonData = LockLibLocalCachedData() else {
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
        
        func changePassword(oldPassword:String, newPassword:String)->String?{
                var err: NSError? = nil
                LockLibChangePassword(oldPassword,newPassword, &err)
                
                if let e = err {
                        return e.localizedDescription
                }
                return nil
        }
        
        func getVersion() -> String {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Build"
                return "Version \(version) (Build \(build))"
        }
        
        func getAutoCloseDuration()->Int{
                return LockLibKeyExpireTime()
        }
        
        func setAutoCloseDuration(_ clockTime:Int)->Bool{
                var err: NSError? = nil
                LockLibSaveExpireTime(clockTime, &err)
                if let e = err {
                        print("Failed to Saved Wallet Clock Time: \(e.localizedDescription)")
                        return false
                }
                
                print("Wallet Clock Time Saved Success: \(clockTime)")
                return true
        }
}

// MARK: - 实现 Go 的 APPI 接口
extension SdkUtil: LockLibAppIProtocol {
        
        func closeWallet() {
                DispatchQueue.main.async {
                        self.appState?.isPasswordValidated = false
                }
        }
        
        func dataUpdated(_ data: Data?, err: (any Error)?) {
                DispatchQueue.main.async {
                        if let error = err {
                                self.toastManager?.showToast(message: "Data update failed: \(error.localizedDescription)", isSuccess: false)
                        } else {
                                self.toastManager?.showToast(message: "Data updated successfully!", isSuccess: true)
                        }
                }
        }
        
        @objc func log(_ s: String?) {
                print("[GoSDK] \(s ?? "")")
        }
}
