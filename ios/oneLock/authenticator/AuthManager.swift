//
//  AuthManager.swift
//  oneLock
//
//  Created by wesley on 2025/1/16.
//


import SwiftUI
import Combine

class AuthManager: ObservableObject {
        @Published var accounts: [String: AuthAccount] = [:]
        
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
                DispatchQueue.main.async {
                        self.accounts = SdkUtil.shared.loadAuthAccounts()
                }
        }
}
