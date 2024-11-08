import Foundation
import Combine

final class ConnectWalletViewModel: ObservableObject {
    @Published var secretKey: String = ""
    
    private let addedWalletSubject: PassthroughSubject<Wallet, Never>
    
    private let walletManagerProvider:  WalletManagerProvider
    
    init(conteiner: DependencyContainer = .shared,
         addedWalletSubject: PassthroughSubject<Wallet, Never>) {
        walletManagerProvider = conteiner.resolve()
        self.addedWalletSubject = addedWalletSubject
    }
    
    func addWallet(name: String? = "") {
        guard let newWallet = walletManagerProvider.addWallet(secretKey: secretKey, name: name)  else { return }
        addedWalletSubject.send(newWallet)
    }
    
    func createWallet(name: String? = "") {
        guard let newWallet = walletManagerProvider.createWallet(name: name) else { return }
        addedWalletSubject.send(newWallet)
    }
}


