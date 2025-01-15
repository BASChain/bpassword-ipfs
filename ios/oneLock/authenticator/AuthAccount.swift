//
//  Account.swift
//  oneLock
//
//  Created by wesley on 2025/1/15.
//


import Foundation

struct AuthAccount: Codable {
        let issuer: String
        let account: String
        var code: String
        var timeLeft: Int
        
        // 自定义 CodingKeys
        enum CodingKeys: String, CodingKey {
                case issuer
                case account
                case code
                case timeLeft
        }
        
        // 自定义解码
        init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                issuer   = try container.decode(String.self, forKey: .issuer)
                account  = try container.decode(String.self, forKey: .account)
                // 若缺失 code/timeLeft 字段，则使用默认值
                code     = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
                timeLeft = try container.decodeIfPresent(Int.self, forKey: .timeLeft) ?? 0
        }
        
        // 原先的便利 init 依然可以保留
        init(issuer: String, account: String, code: String="", timeLeft: Int=0) {
                self.issuer = issuer
                self.account = account
                self.code = code
                self.timeLeft = timeLeft
        }
}
