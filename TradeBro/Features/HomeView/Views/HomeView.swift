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
                            .background {
                                viewModel.sentToken?.mint == token.mint ? Color.gray : Color.clear
                            }
                            .onTapGesture {
                                viewModel.sentToken = token
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
            
            if viewModel.sentToken != nil {
                sentToken
            }
        }
        .padding()
    }

    private var sentToken: some View {
            VStack {
                TextField("Recipient Address", text: $viewModel.sentTokenToAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Amount", text: $viewModel.sentTokenAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.numberPad)
                
                Button(action: {
                    Task {
                        await viewModel.sendSPLTokens()
                    }
                }) {
                    Text("Send Tokens")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
}


