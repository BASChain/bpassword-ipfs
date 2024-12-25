//
//  WalletSetupView.swift
//  oneLock
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI

struct WalletSetupView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                Text("No Wallet Detected")
                    .font(.title)
                NavigationLink(destination: CreateWalletView().environmentObject(appState)) {
                    Text("Create Wallet")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                Button("Import Wallet") {
                    // Navigate to import wallet
                }
                .padding()
            }
            .navigationTitle("Wallet Setup")
        }
    }
}
