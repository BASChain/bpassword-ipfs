//
//  Account.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//
import SwiftUI

struct Account: Identifiable {
    let id = UUID()
    let platform: String
    let username: String
    let password: String
    let lastUpdated: String
}
