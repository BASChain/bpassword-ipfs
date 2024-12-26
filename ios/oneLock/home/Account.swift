//
//  Account.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//

import SwiftUI
import Foundation

struct Account: Identifiable, Codable {
        var id: UUID // 允许解码时覆盖
        let platform: String
        let username: String
        let password: String
        let lastUpdated: Int64 // 修改为 Unix 时间戳
        
        init(id: UUID = UUID(), platform: String, username: String, password: String, lastUpdated: Int64 = Int64(Date().timeIntervalSince1970)) {
                self.id = id
                self.platform = platform
                self.username = username
                self.password = password
                self.lastUpdated = lastUpdated
        }
        
        func jsonString() -> String? {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                do {
                        let data = try encoder.encode(self)
                        return String(data: data, encoding: .utf8)
                } catch {
                        print("Failed to encode Account to JSON: \(error.localizedDescription)")
                        return nil
                }
        }
        
        func formattedLastUpdated() -> String {
                let date = Date(timeIntervalSince1970: TimeInterval(lastUpdated))
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
        }
}
