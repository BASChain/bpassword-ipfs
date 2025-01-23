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
enum SdkError: Error {
        case serializationFailed
        case account(String)
        case authSaveFailed(String)
        case wallet(String)
        case sdk(String)
        case setting(String)
}
// 定义一个类以实现日志处理
class SdkUtil: NSObject {
        // MARK: - 单例模式
        static let shared = SdkUtil()
        private let server_url = "https://bc.simplenets.org:5001"
        //        private let server_url = "http://192.168.18.51:5004"
        private let server_token = "ac8ad031c9905e3ead2454d1a1f6c110"
        static let AppUrl = "https://apps.apple.com/us/app/onelock/id6739830100"
        weak var authManager: AuthManager? = nil
        var toastManager: ToastManager? // 引用 ToastManager
        @Published var shouldRefreshAccounts: Bool = false
        private override init() {
                super.init()
        }
        
        private func getDatabasePath() -> String {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDirectory = paths[0]
                return documentDirectory.appendingPathComponent("oneLockDb").path
        }
        
        // MARK: - 方法
        func initializeSDK(logLevel: LogLevel)throws{
                var err:NSError? = nil
                LockLibInitSDK(self,server_url, server_token, logLevel.rawValue, &err)
                if let error = err {
                        throw SdkError.sdk("Failed to initialize SDK: \(error.localizedDescription)")
                }
        }
        
        func initWalletStatus() -> Bool {
                let dbPath = getDatabasePath()
                return LockLibInitWalletPath(dbPath)
        }
        
        func generateMnemonic()throws -> String {
                var err: NSError? = nil
                
                // 调用 Go 侧 API 生成助记词数据
                guard let mnemonicData = LockLibGenerateMnemonic(&err) else {
                        print("Error generating mnemonic: \(err?.localizedDescription ?? "Unknown error").")
                        throw SdkError.sdk("Error generating mnemonic: \(err?.localizedDescription ?? "Unknown error").")
                }
                
                // 将助记词数据解码为字符串
                guard let mnemonicString = String(data: mnemonicData as Data, encoding: .utf8) else {
                        print("Failed to decode mnemonic data.")
                        throw SdkError.sdk("Failed to decode mnemonic data.")
                }
                
                return mnemonicString
        }
        
        func createWallet(mnemonic: String,password:String)throws {
                var err: NSError? = nil
                LockLibGenerateWallet(mnemonic,password, &err)
                guard let e = err else{
                        return
                }
                
                print("Failed to create wallet\(e.localizedDescription).")
                throw SdkError.wallet("Failed to create wallet:\(e.localizedDescription).")
        }
        
        
        func openWallet(password:String)throws{
                var err: NSError? = nil
                LockLibOpenWallet(password,&err)
                guard let e = err else{
                        syncLocalData()
                        return
                }
                
                print("Failed to open wallet\(e.localizedDescription).")
                throw SdkError.wallet("Failed to open wallet:\(e.localizedDescription).")
        }
        
        
        func changePassword(oldPassword:String, newPassword:String)throws{
                var err: NSError? = nil
                LockLibChangePassword(oldPassword,newPassword, &err)
                if let e = err {
                        throw SdkError.wallet("Failed to change password:\(e.localizedDescription).")
                }
        }
        
        func syncLocalData(){
                LockLibInitLocalData()
        }
        
        func walletAddress()->String{
                return LockLibWalletAddress()
        }
        
        
        func addAccount(account: Account) throws {
                // 将 Account 实例转换为 JSON 字符串
                guard let jsonStr = account.jsonString() else {
                        throw SdkError.serializationFailed
                }
                
                var err: NSError? = nil
                // 调用 C 函数进行添加或更新
                LockLibAddOrUpdateAccount(jsonStr, &err)
                
                // 如果有错误，抛出异常
                guard let error = err  else {
                        return;
                }
                
                throw SdkError.account(error.localizedDescription)
        }
        func loadAccounts() -> [UUID: Account] {
                var accountsMap = [UUID: Account]()
                
                guard let jsonData = LockLibLocalCachedData() else {
                        return accountsMap
                }
                
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
        
        func removeAccount(uuid: UUID)throws {
                
                var err: NSError? = nil
                LockLibRemoveAccount(uuid.uuidString, &err)
                
                if let e = err {
                        print("Failed to remove account: \(e.localizedDescription)")
                        throw SdkError.account("Failed to remove account: \(e.localizedDescription)")
                }
                
                print("Account successfully removed: \(uuid.uuidString)")
        }
        
        func getVersion() -> String {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Build"
                return "Version \(version) (Build \(build))"
        }
        
        func getAutoCloseDuration()->Int{
                return LockLibKeyExpireTime()
        }
        
        func setAutoCloseDuration(_ clockTime:Int)throws{
                
                var err: NSError? = nil
                LockLibSaveExpireTime(clockTime, &err)
                
                if let e = err {
                        print("Failed to Saved Wallet Clock Time: \(e.localizedDescription)")
                        throw SdkError.setting("Failed to Saved Wallet Clock Time: \(e.localizedDescription)")
                }
                
                print("Wallet Clock Time Saved Success: \(clockTime)")
        }
        
        func loadAuthAccounts() -> [String: AuthAccount] {
                var accountsMap = [String: AuthAccount]()
                
                guard let jsonData = LockLibLocalCachedAuth() else {
                        return accountsMap
                }
                do {
                        let decoder = JSONDecoder()
                        let decodedAccounts = try decoder.decode([String: AuthAccount].self, from: jsonData)
                        for (key, account) in decodedAccounts {
                                accountsMap[key] = account
                        }
                        
                } catch {
                        print("Failed to decode accounts JSON: \(error.localizedDescription)")
                }
                
                return accountsMap
        }
        
        func NewAuthManual(issuer:String, account:String, secret:String) throws -> Bool {
                var err: NSError? = nil
                
                LockLibNewManualAuth(issuer,account,secret, &err)
                
                if err == nil {
                        print("Auth mannual successfully saved.")
                        return true
                }
                
                if let error = err {
                        throw SdkError.authSaveFailed(error.localizedDescription)
                }
                
                return false
        }
        
        func NewAuthScanned(code:String) throws{
                
                var err: NSError? = nil
                LockLibNewScanAuth(code,&err)
                
                if err == nil {
                        print("Auth successfully saved.")
                        return
                }
                
                if let error = err {
                        throw SdkError.authSaveFailed(error.localizedDescription)
                }
                return
        }
        
        func DelAuth(key:String) throws{
                var err: NSError? = nil
                
                LockLibRemoveAuth(key,&err)
                
                if err == nil {
                        print("Auth successfully saved.")
                        return
                }
                
                if let error = err {
                        throw SdkError.authSaveFailed(error.localizedDescription)
                }
                return
                
        }
        
        func logout(){
                DispatchQueue.global().async {
                        LockLibCloseWallet()
                        DispatchQueue.main.async {
                                AppStateManager.shared.appState.isPasswordValidated = false
                        }
                }
        }
        
        func deleteAccount(){
                LockLibCompleteRemoveWallet()
                DispatchQueue.main.async {
                        AppStateManager.shared.appState.hasWallet = false
                        AppStateManager.shared.appState.isPasswordValidated = false
                }
        }
}

// MARK: - 实现 Go 的 APPI 接口
extension SdkUtil: LockLibAppIProtocol {
        
        func authCodeUpdate(_ key: String?, code: String?, timeleft: Int) {
                guard let k = key, let c = code else{
                        return
                }
                
                //                print("--->>key \(k) code \(c) time left:\(timeleft)")
                
                DispatchQueue.main.async {
                        if let manager = SdkUtil.shared.authManager {
                                manager.updateAuthCode(for: k, code: c, timeLeft: timeleft)
                        }
                }
        }
        
        func authDataUpdated(_ data: Data?, err: (any Error)?) {
                guard let error = err else{
                        return
                }
                self.toastManager?.showToast(message: "Authenticator data update failed: \(error.localizedDescription)", isSuccess: false)
        }
        
        
        func closeWallet() {
                DispatchQueue.main.async {
                        AppStateManager.shared.appState.isPasswordValidated = false
                }
        }
        
        func dataUpdated(_ data: Data?, err: (any Error)?) {
                DispatchQueue.main.async {
                        if let error = err {
                                self.toastManager?.showToast(message: "Data update failed: \(error.localizedDescription)", isSuccess: false)
                        } else {
                                self.toastManager?.showToast(message: "Data updated successfully!", isSuccess: true)
                                DispatchQueue.main.async {
                                        self.shouldRefreshAccounts = true
                                }
                        }
                }
        }
        
        @objc func log(_ s: String?) {
                print("[GoSDK] \(s ?? "")")
        }
}
