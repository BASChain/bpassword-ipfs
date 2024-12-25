//
//  BPassword_ipfsApp.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI
import SwiftData

@main
struct BPassword_ipfsApp: App {
        
        init() {
                initializeSdk()
        }
        
        var body: some Scene {
                WindowGroup {
                        MainView()
                }
        }
        
        private func initializeSdk() {
                print("Initializing SDK...")
                SdkUtil.shared.initializeSDK(logLevel: LogLevel.debug)
                print("SDK initialized.")
        }
}
