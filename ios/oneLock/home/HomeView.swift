import SwiftUI

struct HomeView: View {
        @State private var accounts: [UUID: Account] = [:]
        
        var body: some View {
                NavigationView {
                        VStack {
                                if accounts.isEmpty {
                                        Text("No accounts found.")
                                                .foregroundColor(.gray)
                                                .padding()
                                } else {
                                        List(sortedAccounts(), id: \.id) { account in
                                                NavigationLink(destination: AccountDetailView(account: account)) {
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
                                        NavigationLink(destination: AddAccountView(onSave: loadAccounts)) { // 传递刷新回调
                                                Image(systemName: "plus")
                                        }
                                }
                        }
                        .onAppear(perform: loadAccounts)
                }
        }
        
        private func loadAccounts() {
                accounts = SdkUtil.shared.loadAccounts()
        }
        
        private func sortedAccounts() -> [Account] {
                return accounts.values.sorted { $0.lastUpdated > $1.lastUpdated }
        }
}
