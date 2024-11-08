import SwiftUI

final class WalletViewModel: ObservableObject {
    @Published var wallet: Wallet
    
    @Published var solBalance: Double?
    @Published var tokenBalances: [SolToken] = []
    
    @Published var sentSolToAddress: String = ""
    @Published var sentSolAmount: String = ""
    
    @Published var sentToken: SolToken?
    @Published var sentTokenToAddress: String = ""
    @Published var sentTokenAmount: String = ""
    
    private let walletManager: WalletManagerProvider
    private let walletInfoManager: WalletInfoManagerProvider
    private let transactionManager: TransactionManagerProvider
    
    init(conteiner: DependencyContainer = .shared,
         wallet: Wallet) {
        walletManager = conteiner.resolve()
        walletInfoManager = conteiner.resolve()
        transactionManager = conteiner.resolve()
        
        self.wallet = wallet
        
        fetchTokenBalances()
    }
    
    func fetchTokenBalances() {
        Task {
            do {
                let balances = try await walletInfoManager.getTokenBalances(for: wallet.keyPair.publicKey.base58EncodedString)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    solBalance = balances.solBalance
                    tokenBalances = balances.tokenBalances
                }
            } catch {
                debugOutput("Error fetching token balances: \(error)")
            }
        }
    }
}

