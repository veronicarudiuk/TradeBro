import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet]
    @Published var activeWallet: Wallet?
    @Published var isDropdownVisible = false
    @Published var isConnectWalletVisible = false
    
    private let userDefaultsManager: UserDefaultsProvider
    private let walletManagerProvider: WalletManagerProvider
    
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
        self.activeWallet = wallet
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




//import SwiftUI
////import SolanaSwift
////import KeychainAccess
//
//final class HomeViewModel: ObservableObject {
////    @Published var publicKey: String = ""
////    @Published private var secretKey: String = ""
//
////    @Published var solBalance: Double?
////    @Published var tokenBalances: [SolToken] = []
//
////    private let keychain = Keychain(service: "com.yourapp.service")
////    private let tokenProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
////    private let endpoint = APIEndPoint(
////        address: "https://api.mainnet-beta.solana.com",
////        network: .mainnetBeta
////    )
////    private lazy var solanaAPIClient = JSONRPCAPIClient(endpoint: endpoint)
//
////    private var blockchainClient: BlockchainClient {
////        BlockchainClient(apiClient: solanaAPIClient)
////    }
//
////    private let radiumAPI: RadiumClientAPIProvider
//
////    private var keyPair: KeyPair?
//
////    @Published var sentToken: SolToken?
////    @Published var sentTokenToAddress: String = ""
////    @Published var sentTokenAmount: String = ""
//
//    init(conteiner: DependencyContainer = .shared) {
////        radiumAPI = conteiner.resolve()
////        loadWallet()
//    }
//}
//
//////MARK: - Wallet Loading
////extension HomeViewModel {
////    func loadWallet() {
////        if let savedPublicKey = keychain.allKeys().first,
////           let keyPair = loadFromKeychain(publicKey: savedPublicKey) {
////            DispatchQueue.main.async {
////                self.keyPair = keyPair
////                self.publicKey = keyPair.publicKey.base58EncodedString
////                self.secretKey = keyPair.secretKey.toHexString()
////            }
////        }
////    }
////
////    private func loadFromKeychain(publicKey: String) -> KeyPair? {
////        do {
////            if let secretKeyData = try keychain.getData(publicKey) {
////                return try KeyPair(secretKey: secretKeyData)
////            }
////        } catch {
////            print("Error loading from Keychain: \(error)")
////        }
////        return nil
////    }
////}
//
//////MARK: - Sent Transactions
////extension HomeViewModel {
////    func sendNativeSOL() async {
////        guard let keyPair else { return }
////
////        do {
////            let preparedTransaction = try await blockchainClient.prepareSendingNativeSOL(
////                from: keyPair, to: "DcLmZTuDRMBn7Pd2PkK3FBMG3CEqB1JSqUQVaTB4Kbiu", amount: UInt64(0.0001)
////            )
////
////            let signature = try await blockchainClient.sendTransaction(
////                preparedTransaction: preparedTransaction
////            )
////            print("Transaction successful: \(signature)")
////        } catch {
////            print("Transaction failed: \(error.localizedDescription)")
////        }
////    }
////
////    func sendSPLTokens() async {
////        guard let keyPair, let sentToken, !sentTokenToAddress.isEmpty, !sentTokenAmount.isEmpty else { return }
////
////        guard let amount = UInt64(sentTokenAmount) else {
////            print("Invalid amount format")
////            return
////        }
////
////        do {
////            let tokenProgramId = try PublicKey(string: tokenProgramId)
////            let lamportsPerSignature = try await getLamportsPerSignature()
////            let minRentExemption = try await getMinRentExemption()
////
////
////            let preparedTransaction = try await blockchainClient.prepareSendingSPLTokens(
////                account: keyPair, // ваш аккаунт для подписания
////                mintAddress: sentToken.mint, // адрес выпуска токена
////                tokenProgramId: tokenProgramId,  // программный идентификатор токена
////                decimals: sentToken.tokenMetadata?.decimals ?? 6, // количество десятичных знаков для токена
////                from: sentToken.tokenAccount, // адрес вашего токен-аккаунта
////                to: sentTokenToAddress, // адрес токен-аккаунта получателя
////                amount: amount * 1000000, // количество токенов в лампортах
////                lamportsPerSignature: lamportsPerSignature,  // количество лампортов для комиссии за подпись
////                minRentExemption: minRentExemption // минимальное количество лампортов для освобождения от аренды
////            )
////
////            print("🔫 mintAddress \(sentToken.mint), decimals \(sentToken.tokenMetadata?.decimals ?? 6), from \(sentToken.tokenAccount), to: \(sentTokenToAddress), amount: \(amount), lamportsPerSignature: \(lamportsPerSignature), minRentExemption: \(minRentExemption)")
////
////            let signature = try await blockchainClient.sendTransaction(
////                preparedTransaction: preparedTransaction.preparedTransaction
////            )
////
////            print("Transaction successful: \(signature)")
////        } catch {
////            print("Transaction failed: \(error.localizedDescription)")
////        }
////    }
////
////    func getLamportsPerSignature() async throws -> UInt64 {
////        let feesResponse = try await solanaAPIClient.getFees(commitment: "finalized")
////        return feesResponse.feeCalculator?.lamportsPerSignature ?? 500
////    }
////
////    func getMinRentExemption() async throws -> UInt64 {
////        let requiredDataLength: UInt64 = 165 // стандартное значение для токен аккаунта
////        return try await solanaAPIClient.getMinimumBalanceForRentExemption(dataLength: requiredDataLength)
////    }
////}
//
//
//////MARK: - Get Tokens
////extension HomeViewModel {
////    func getTokenBalances() async {
////        await getSolBalance()
////        await getSplTokenBalances()
////    }
////
////    // баланс sol
////    func getSolBalance() async {
////        do {
////            let balance = try await solanaAPIClient.getBalance(account: publicKey, commitment: "recent")
////
////            DispatchQueue.main.async {
////                self.solBalance = Double(balance) / 1000000000
////            }
////            print("Баланс SOL: \(balance) лампортов = \(solBalance ?? 0) SOL")
////        } catch {
////            print("Ошибка при получении баланса SOL: \(error)")
////        }
////    }
////
////    // баланс токенов
////    func getSplTokenBalances() async  {
////        do {
////            var balances: [SolToken] = []
////
////            // Получение токенов по владельцу
////            let tokenAccounts = try await getTokenAccountsByOwner()
////            print("💀 tokenAccounts \(tokenAccounts)")
////
////            // Получение метаданных токенов
////            let metadataResponse = try await getTokenMetadata(tokenAccounts: tokenAccounts)
////            print("💔 metadataResponse \(metadataResponse)")
////
////            // Получение цен токенов
////            let tokenPrices = try await getTokenPrices()
////
////            for tokenAccount in tokenAccounts {
////                let token = try await getTokenInfo(
////                    tokenAccount: tokenAccount,
////                    metadataResponse: metadataResponse,
////                    tokenPrices: tokenPrices
////                )
////                balances.append(token)
////            }
////
////            let sortedBalances = balances.sorted(by: compareTokensByPrice)
////
////            DispatchQueue.main.async {
////                self.tokenBalances = sortedBalances
////            }
////        } catch {
////            debugOutput("\(#function) error \(error)")
////        }
////    }
////
////    // Получение токенов по владельцу
////    func getTokenAccountsByOwner() async throws ->  [TokenAccount<TokenAccountState>] {
////        try await solanaAPIClient.getTokenAccountsByOwner(
////            pubkey: publicKey,
////            params: OwnerInfoParams(mint: nil, programId: tokenProgramId),
////            configs: RequestConfiguration(encoding: "base64")
////        )
////    }
////
////    // Получение метаданных токенов
////    func getTokenMetadata(tokenAccounts: [TokenAccount<TokenAccountState>]) async throws -> [TokenMetadata] {
////        let mintAddresses = tokenAccounts.map { $0.account.data.mint.base58EncodedString }
////
////        return try await withCheckedThrowingContinuation { continuation in
////            radiumAPI.getTokensMetadata(mintAddresses: mintAddresses) { result in
////                switch result {
////                case .success(let metadata):
////                    continuation.resume(returning: metadata)
////                case .failure(let error):
////                    continuation.resume(throwing: error)
////                }
////            }
////        }
////    }
////
////    // Получение цен токенов
////    func getTokenPrices() async throws -> [String: Double] {
////        return try await withCheckedThrowingContinuation { continuation in
////            radiumAPI.getTokenPrices { result in
////                switch result {
////                case .success(let prices):
////                    continuation.resume(returning: prices)
////                case .failure(let error):
////                    continuation.resume(throwing: error)
////                }
////            }
////        }
////    }
////
////
////    // Функция для получения информации о токене
////    func getTokenInfo(
////        tokenAccount: TokenAccount<TokenAccountState>,
////        metadataResponse: [TokenMetadata],
////        tokenPrices: [String: Double]
////    ) async throws -> SolToken {
////
////        let pubkey = tokenAccount.pubkey
////        let mintAddress = tokenAccount.account.data.mint.base58EncodedString
////        let amount = tokenAccount.account.data.lamports
////        let tokenMetadata = metadataResponse.first { $0.address == mintAddress }
////        let price = tokenPrices[mintAddress]
////
////        let token = SolToken(tokenAccount: pubkey,
////                             mint: mintAddress,
////                             amount: amount,
////                             tokenMetadata: tokenMetadata,
////                             price: price)
////
////        return token
////    }
////
////    func compareTokensByPrice(_ lhs: SolToken, _ rhs: SolToken) -> Bool {
////        let lhsPrice = lhs.totalAmountPriceInUSD ?? 0
////        let rhsPrice = rhs.totalAmountPriceInUSD ?? 0
////        return lhsPrice < rhsPrice
////    }
////}
//
//////MARK: - Create Wallet
////extension HomeViewModel {
////
////    func createWallet() {
////        let keyPair = try! KeyPair()
////        print("Address: \(keyPair.publicKey.base58EncodedString)")
////        print("Private Key: \(keyPair.secretKey.toHexString())")
////
////        publicKey = keyPair.publicKey.base58EncodedString
////        secretKey = keyPair.secretKey.toHexString()
////        saveToKeychain(account: keyPair)
////    }
////
////    func saveToKeychain(account: KeyPair)  {
////        let secretKeyData = account.secretKey
////        let publicKey = account.publicKey.base58EncodedString
////
////        do {
////            try keychain.set(secretKeyData, key: publicKey)
////            print("Saved to Keychain")
////        } catch {
////            print("Error saving to Keychain: \(error)")
////        }
////    }
////}
