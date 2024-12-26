import SwiftUI

struct HomeView: View {
        @State private var accounts: [Account] = [
                Account(platform: "Google", username: "user@gmail.com", password: "password123"),
                Account(platform: "Facebook", username: "user@facebook.com", password: "facebook123")
        ]
        
        var body: some View {
                NavigationView {
                        VStack {
                                if accounts.isEmpty {
                                        Text("No accounts found.")
                                                .foregroundColor(.gray)
                                                .padding()
                                } else {
                                        List(accounts) { account in
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
                                        NavigationLink(destination: AddAccountView()) {
                                                Image(systemName: "plus")
                                        }
                                }
                        }
                }
        }
}
