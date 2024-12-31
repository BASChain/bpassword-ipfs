//
//  ToastManager.swift
//  oneLock
//
//  Created by wesley on 2024/12/31.
//


import SwiftUI

class ToastManager: ObservableObject {
        @Published var isVisible: Bool = false  // 是否显示 Toast
        @Published var message: String = ""    // Toast 提示信息
        @Published var isSuccess: Bool = true  // Toast 状态（成功/失败）
        @Published var duration: Double = 3.0  // 默认显示时长
        
        func showToast(message: String, isSuccess: Bool, duration: Double = 3.0) {
                self.message = message
                self.isSuccess = isSuccess
                self.duration = duration
                self.isVisible = true
                
                // 自动隐藏
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.isVisible = false
                }
        }
}
