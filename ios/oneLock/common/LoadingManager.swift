//
//  LoadingManager.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//


import SwiftUI

class LoadingManager: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var message: String = ""

    static let shared = LoadingManager() // 单例模式

    private init() {}

    func show(message: String) {
        DispatchQueue.main.async {
            self.message = message
            self.isVisible = true
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.isVisible = false
        }
    }
}
