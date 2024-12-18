import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel: WalletViewModel
    
    init(wallet: Wallet) {
        _viewModel = StateObject(wrappedValue: WalletViewModel(wallet: wallet))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            Text("Ваш адрес: \(viewModel.wallet.keyPair.publicKey)")
                .padding()
            
            Text("Баланс Sol: \(viewModel.solBalance != nil ? "\(viewModel.solBalance!)" : "-")")
                .padding()
            
            if viewModel.tokenBalances.isEmpty {
                Text("Балансов токенов нет")
            } else {
                VStack {
                    List(viewModel.tokenBalances, id: \.mint) { token in
                        TokenView(info: token)
                    }
                }
            }
            
            Spacer()
        }
        
    }
}



