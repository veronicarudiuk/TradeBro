import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet]
    @Published var activeWallet: Wallet?
    @Published var isWalletsSheetVisible = false
    @Published var isConnectWalletVisible = false
    
    private let userDefaultsManager: UserDefaultsProvider
    private let walletManagerProvider: WalletManagerProvider
    
    let switchToWalletSubject = PassthroughSubject<Wallet, Never>()
    let addedWalletSubject = PassthroughSubject<Wallet, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(conteiner: DependencyContainer = .shared) {
        userDefaultsManager = conteiner.resolve()
        walletManagerProvider = conteiner.resolve()
        
        wallets = walletManagerProvider.activeWallets
        
        setupSubscriptions()
        loadLastActiveWallet()
    }
    
    private func setupSubscriptions() {
        walletManagerProvider.activeWalletsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.wallets, on: self)
            .store(in: &cancellables)
        
        addedWalletSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                guard let self else { return }
                switchWallet(to: item)
            }
            .store(in: &cancellables)
        
        switchToWalletSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] item in
                guard let self else { return }
                isWalletsSheetVisible = false
                switchWallet(to: item)
            }
            .store(in: &cancellables)
    }
    
    private func loadLastActiveWallet() {
        if let lastWalletPublicKey = userDefaultsManager.loadLastActiveWalletPublicKey(),
           let wallet = wallets.first(where: { $0.keyPair.publicKey.base58EncodedString == lastWalletPublicKey }) {
            activeWallet = wallet
        } else {
            activeWallet = wallets.first
        }
    }
    
    func switchWallet(to wallet: Wallet) {
        activeWallet = wallet
        saveLastActiveWallet(wallet: wallet)
    }
    
    func saveLastActiveWallet(wallet: Wallet) {
        userDefaultsManager.saveLastActiveWalletPublicKey(wallet.keyPair.publicKey.base58EncodedString)
    }
    
    func addWallet(secretKey: String, name: String? = "") {
        guard let newWallet = walletManagerProvider.addWallet(secretKey: secretKey, name: name)  else { return }
        switchWallet(to: newWallet)
    }
    
    func createWallet(name: String? = "") {
        guard let newWallet = walletManagerProvider.createWallet(name: name) else { return }
        switchWallet(to: newWallet)
    }
}


