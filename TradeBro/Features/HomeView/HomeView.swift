import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        VStack {
            if viewModel.publicKey.isEmpty {
                Button("Создать кошелек") {
                    viewModel.createWallet()
                }
                .padding()
            } else {
                Text("Ваш адрес: \(viewModel.publicKey)")
                    .padding()
                
                Text("Баланс Sol: \(viewModel.solBalance != nil ? "\(viewModel.solBalance!)" : "-")")
                    .padding()
                
                Button("Получить балансы токенов") {
                    Task {
                        await viewModel.getTokenBalances()
                    }
                }
                .padding()
                
                if viewModel.tokenBalances.isEmpty {
                    Text("Балансов токенов нет")
                } else {
                    VStack {
                        List(viewModel.tokenBalances, id: \.mint) { token in
                            VStack(alignment: .leading) {
                                Text("Mint: \(token.mint)")
                                HStack() {
                                    KFImageView(urlString: token.tokenMetadata?.logoURI)
                                        .frame(width: 50,
                                               height: 50)
                                        .padding()
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(token.tokenMetadata?.name ?? "-")")
                                        HStack() {
                                            Text("\(token.realAmount)")
                                            Text("\(token.tokenMetadata?.symbol ?? "-")")
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Total: $\(token.totalAmountPriceInUSDString)")
                                        Text("Token price: $\(token.priceString)")
                                    }
                                }
                            }
                        }
                        
                        Button("Отправить 0.0001 sol") {
                            Task {
                                await viewModel.sendNativeSOL()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .padding()
    }

}


