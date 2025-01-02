import SwiftUI

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
