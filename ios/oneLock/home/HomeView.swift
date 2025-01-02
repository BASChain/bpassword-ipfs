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
                                } else {
                                        List(sortedAccounts(), id: \.id) { account in
                                                NavigationLink(
                                                        destination: AccountDetailView(
                                                                account: bindingForAccount(account), // 传递绑定
                                                                onAccountDeleted: { hasLoaded = false } // 设置 hasLoaded 为 false
                                                        )
                                                ) {
                                                        HStack {
                                                                Text(account.platform)
                                                                        .font(.headline)
                                                                Spacer()
                                                                Text(account.formattedLastUpdated())
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.gray)
                                                        }
                                                }
                                        }
                                }
                        }
                        .navigationTitle("Account Manager")
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        NavigationLink(destination: AddAccountView(onSave: loadAccounts)) {
                                                Image(systemName: "plus")
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
