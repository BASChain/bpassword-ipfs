//
//  MnemonicView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI
struct MnemonicView: View {
        let mnemonic: String
        let password: String
        @State private var isButtonPressed: Bool = false
        @State private var isLoading: Bool = false
        @State private var errorMessage: String? = nil
        
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var appState: AppState
        
        var body: some View {
                VStack(spacing: 20) {
                        Text("Backup Your Mnemonic Phrase")
                                .font(.headline)
                                .padding(.top)
                        
                        Text("Keep this phrase secure and offline. It is the only way to recover your wallet.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        
                        ZStack {
                                ScrollView {
                                        Text(mnemonic)
                                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(10)
                                                .opacity(isButtonPressed ? 1.0 : 0.0)
                                }
                                .frame(height: 150)
                                
                                if !isButtonPressed {
                                        Color.black.opacity(0.7)
                                                .cornerRadius(10)
                                                .frame(height: 150)
                                        Text("Press and Hold to View")
                                                .foregroundColor(.white)
                                                .font(.body)
                                                .bold()
                                }
                        }
                        .padding()
                        
                        Button(action: {}) {
                                Text("Press and Hold to View Mnemonic")
                        }
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                                if !isLoading {
                                        withAnimation {
                                                isButtonPressed = isPressing
                                        }
                                }
                        }, perform: {})
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        if isLoading {
                                ProgressView()
                                        .padding()
                        } else {
                                Button(action: createWallet) {
                                        Text("I have backed up my mnemonic")
                                }
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        if let error = errorMessage {
                                Text(error)
                                        .foregroundColor(.red)
                                        .padding()
                        }
                }
                .padding()
        }
        
        private func createWallet() {
                isLoading = true
                errorMessage = nil
                
                DispatchQueue.global().async {
                        let success = SdkUtil.shared.createWallet(mnemonic: mnemonic, password: password)
                        DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                        appState.hasWallet = true
                                } else {
                                        errorMessage = "Failed to create wallet. Please try again."
                                }
                        }
                }
        }
        
}
