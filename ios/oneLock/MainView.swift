//
//  ContentView.swift
//  BPassword-ipfs
//
//  Created by wesley on 2024/12/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
        var body: some View {
                TabView {
                        HomeView()
                                .tabItem {
                                        Label("Home", systemImage: "house")
                                }
                        
                        SettingView()
                                .tabItem {
                                        Label("Setting", systemImage: "gearshape")
                                }
                }
        }
}
