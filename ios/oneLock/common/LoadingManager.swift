//
//  LoadingManager.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//


import Combine
import SwiftUI

class LoadingManager: ObservableObject {
        @Published var isVisible: Bool = false
        @Published var message: String = "Loading..." // 默认提示内容
        
        // 展示加载视图
        func show(message: String = "Loading...") {
                DispatchQueue.main.async {
                        self.message = message
                        self.isVisible = true
                }
        }
        
        // 隐藏加载视图
        func hide() {
                DispatchQueue.main.async {
                        self.isVisible = false
                }
        }
        
        // 更新提示内容
        func updateMessage(_ newMessage: String) {
                DispatchQueue.main.async {
                        self.message = newMessage
                }
        }
}
