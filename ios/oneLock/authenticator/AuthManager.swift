//
//  AuthManager.swift
//  oneLock
//
//  Created by wesley on 2025/1/16.
//


import SwiftUI
import Combine

class AuthManager: ObservableObject {
        // 用 @Published 保证 SwiftUI 自动刷新
        @Published var accounts: [String: AuthAccount] = [:]
        
        // 你也可以持有 SdkUtil.shared，但要小心循环引用
        // 或者反过来，在 SdkUtil 中弱引用这个 AuthManager
        init() {
                SdkUtil.shared.authManager = self
                // 初始化可以加载一下现有数据
                accounts = SdkUtil.shared.loadAuthAccounts()
        }
        
        /// 根据 key 更新某个 AuthAccount 的 code、remainingTime
        func updateAuthCode(for key: String, code: String, timeLeft: Int) {
                guard var account = accounts[key] else { return }
                account.code = code
                account.timeLeft = timeLeft
                accounts[key] = account
        }
        
        /// 重新从 SdkUtil 加载所有 AuthAccount
        func reloadAccounts() {
                accounts = SdkUtil.shared.loadAuthAccounts()
        }
        
        // 其他你需要的操作……
}
