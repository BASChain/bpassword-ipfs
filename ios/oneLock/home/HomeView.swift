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
                                                                account: account,
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
}
