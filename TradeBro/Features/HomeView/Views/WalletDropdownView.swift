import SwiftUI

struct WalletDropdownView: View {
    let wallets: [Wallet]
    var onSelect: (Wallet) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(wallets) { wallet in
                Button(action: {
                    onSelect(wallet)
                }) {
                    Text(wallet.keyPair.publicKey.base58EncodedString)
                        .foregroundStyle(.textDark)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onAppear {
                    debugOutput(wallet.displayName)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
