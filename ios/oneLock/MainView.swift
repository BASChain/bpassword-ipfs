import SwiftUI

struct MainView: View {
        @State private var selectedTab: Int = 0 // 用于跟踪选中的 Tab
        
        init() {
                // 创建 UITabBarAppearance 实例
                let appearance = UITabBarAppearance()
                
                // 设置未选中状态下的文字和图标颜色
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
                
                // 设置选中状态下的文字和图标颜色
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 15/255, green: 211/255, blue: 212/255, alpha: 1.0) // #0FD3D4
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 15/255, green: 211/255, blue: 212/255, alpha: 1.0)] // #0FD3D4
                
                // 应用设置
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                }
        }
        
        var body: some View {
                TabView(selection: $selectedTab) {
                        
                        HomeView()
                                .tabItem {
                                        Image(selectedTab == 0 ? "home_icon" : "home_vis_icon")
                                        Text("Home")
                                }
                                .tag(0)
                        
                        AuthenticatorView()
                                .tabItem {
                                        Image(selectedTab == 1 ? "authen_vis_icon" : "authen_icon")
                                        Text("Authenticator")
                                }
                                .tag(1)
                        
                        SettingView()
                                .tabItem {
                                        Image(selectedTab == 2 ? "set_vis_icon" : "set_icon")
                                        Text("Settings")
                                }
                                .tag(2)
                }
        }
}
