import SwiftUI

struct HomeView: View {
        @State private var accounts: [UUID: Account] = [:]
        @State private var hasLoaded = false // 防止重复加载
        
        var body: some View {
                NavigationView {
                        VStack {
                                if accounts.isEmpty {
                                        Text("No accounts found.")
                                                .foregroundColor(.gray)
                                                .padding()
                                } else  {
                                        ScrollView {
                                                VStack(spacing: 12) {
                                                        ForEach(sortedAccounts(), id: \.id) { account in
                                                                NavigationLink(destination: AccountDetailView(account: bindingForAccount(account)){
                                                                        hasLoaded = false
                                                                }) {
                                                                        HStack {
                                                                                VStack(alignment: .leading, spacing: 5) {
                                                                                        Text(account.platform)
                                                                                                .font(.custom("SF Pro Text", size: 19).weight(.medium))
                                                                                                .foregroundColor(Color.black)
                                                                                }
                                                                                Spacer()
                                                                                Text(account.formattedLastUpdated())
                                                                                        .font(.custom("Helvetica Neue", size: 16))
                                                                                        .foregroundColor(Color(red: 137/255, green: 145/255, blue: 155/255))
                                                                                Image("next_icon")
                                                                                        .resizable()
                                                                                        .frame(width: 16, height: 16)
                                                                        }
                                                                        .frame(height: 52) // 设置条目高度
                                                                        .padding(8) // 设置元素的内部间距
                                                                        .background(Color(red: 243/255, green: 249/255, blue: 250/255))
                                                                        .cornerRadius(13) // 设置圆角背景
                                                                }
                                                                .buttonStyle(PlainButtonStyle()) // 确保没有默认样式
                                                        }
                                                }
                                                .padding(.horizontal, 16) // 设置列表整体左右间距
                                        }
                                }
                        }
                        .navigationBarTitle("Account Manager", displayMode: .inline)
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        NavigationLink(destination: AddAccountView(onSave: loadAccounts)) {
                                                Image("add_icon")
                                        }
                                }
                        }
                        .onAppear {
                                loadAccountsIfNeeded()
                        }
                }
        }
        
        private func loadAccountsIfNeeded() {
                if !hasLoaded {
                        loadAccounts()
                }
        }
        
        private func loadAccounts() {
                accounts = SdkUtil.shared.loadAccounts()
                hasLoaded = true
        }
        
        private func sortedAccounts() -> [Account] {
                return accounts.values.sorted { $0.lastUpdated > $1.lastUpdated }
        }
        
        /// 根据 `Account` 获取绑定
        private func bindingForAccount(_ account: Account) -> Binding<Account> {
                guard let uuid = accounts.first(where: { $0.value.id == account.id })?.key else {
                        fatalError("Account not found")
                }
                return Binding(
                        get: { self.accounts[uuid]! },
                        set: { self.accounts[uuid] = $0 }
                )
        }
}
