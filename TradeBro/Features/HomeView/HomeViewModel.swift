import SwiftUI
import SolanaSwift
import KeychainAccess

final class HomeViewModel: ObservableObject {
    @Published var publicKey: String = ""
    @Published private var secretKey: String = ""
    
    @Published var solBalance: Double?
    @Published var tokenBalances: [SolToken] = []
    
    private let keychain = Keychain(service: "com.yourapp.service")
    private let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    private lazy var solanaAPIClient = JSONRPCAPIClient(endpoint: endpoint)
    
    private var blockchainClient: BlockchainClient {
        BlockchainClient(apiClient: solanaAPIClient)
    }
    
    private let radiumAPI: RadiumClientAPIProvider
    
    private var keyPair: KeyPair?
    
    init(conteiner: DependencyContainer = .shared) {
        radiumAPI = conteiner.resolve()
        loadWallet()
    }
}

//MARK: - Wallet Loading
extension HomeViewModel {
    func loadWallet() {
        if let savedPublicKey = keychain.allKeys().first,
           let keyPair = loadFromKeychain(publicKey: savedPublicKey) {
            DispatchQueue.main.async {
                self.keyPair = keyPair
                self.publicKey = keyPair.publicKey.base58EncodedString
                self.secretKey = keyPair.secretKey.toHexString()
            }
        }
    }
    
    private func loadFromKeychain(publicKey: String) -> KeyPair? {
        do {
            if let secretKeyData = try keychain.getData(publicKey) {
                return try KeyPair(secretKey: secretKeyData)
            }
        } catch {
            print("Error loading from Keychain: \(error)")
        }
        return nil
    }
}

//MARK: - Sent Transactions
extension HomeViewModel {
//    func sendNativeSOL(toAddress: String, amount: UInt64) async {
    func sendNativeSOL() async {
        guard let keyPair else { return }
        
        do {
            let preparedTransaction = try await blockchainClient.prepareSendingNativeSOL(
                from: keyPair, to: "DcLmZTuDRMBn7Pd2PkK3FBMG3CEqB1JSqUQVaTB4Kbiu", amount: UInt64(0.0001)
            )
            
            let signature = try await blockchainClient.sendTransaction(
                preparedTransaction: preparedTransaction
            )
            print("Transaction successful: \(signature)")
        } catch {
            print("Transaction failed: \(error.localizedDescription)")
        }
    }
    
    func sendSPLTokens(fromAddress: String, toAddress: String, mintTokenAddress: String, amount: UInt64, decimals: UInt8) async {
        guard let keyPair else { return }
        
        do {
            let tokenProgramId = try PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA") // стандартный программный идентификатор токена
            let lamportsPerSignature = try await getLamportsPerSignature()
            let minRentExemption = try await getMinRentExemption()
            
            
            let preparedTransaction = try await blockchainClient.prepareSendingSPLTokens(
                account: keyPair, // ваш аккаунт для подписания
                mintAddress: mintTokenAddress, // адрес выпуска токена
                tokenProgramId: tokenProgramId,  // программный идентификатор токена
                decimals: decimals, // количество десятичных знаков для токена
                from: fromAddress, // адрес вашего токен-аккаунта
                to: toAddress, // адрес токен-аккаунта получателя
                amount: amount, // количество токенов в лампортах
                lamportsPerSignature: lamportsPerSignature,  // количество лампортов для комиссии за подпись
                minRentExemption: minRentExemption // минимальное количество лампортов для освобождения от аренды
            )
            
            let signature = try await blockchainClient.sendTransaction(
                preparedTransaction: preparedTransaction.preparedTransaction
            )
            
            print("Transaction successful: \(signature)")
        } catch {
            print("Transaction failed: \(error.localizedDescription)")
        }
    }
    
    func getLamportsPerSignature() async throws -> UInt64 {
        let feesResponse = try await solanaAPIClient.getFees(commitment: "finalized")
        return feesResponse.feeCalculator?.lamportsPerSignature ?? 500
    }
    
    func getMinRentExemption() async throws -> UInt64 {
        let requiredDataLength: UInt64 = 165 // стандартное значение для токен аккаунта
        return try await solanaAPIClient.getMinimumBalanceForRentExemption(dataLength: requiredDataLength)
    }
}


//MARK: - Get Tokens
extension HomeViewModel {
    func getTokenBalances() async {
        await getSolBalance()
        await getSplTokenBalances()
    }
    
    // баланс sol
    func getSolBalance() async {
        do {
            let balance = try await solanaAPIClient.getBalance(account: publicKey, commitment: "recent")
            
            DispatchQueue.main.async {
                self.solBalance = Double(balance) / 1000000000
            }
            print("Баланс SOL: \(balance) лампортов = \(solBalance ?? 0) SOL")
        } catch {
            print("Ошибка при получении баланса SOL: \(error)")
        }
    }
    
    // баланс токенов
    func getSplTokenBalances() async  {
        do {
            var balances: [SolToken] = []
            
            // Получение токенов по владельцу
            let tokenAccounts = try await getTokenAccountsByOwner()
            print("💀 tokenAccounts \(tokenAccounts)")
            
            // Получение метаданных токенов
            let metadataResponse = try await getTokenMetadata(tokenAccounts: tokenAccounts)
            print("💔 metadataResponse \(metadataResponse)")
            
            // Получение цен токенов
            let tokenPrices = try await getTokenPrices()
            
            for tokenAccount in tokenAccounts {
                let token = try await getTokenInfo(
                    tokenAccount: tokenAccount,
                    metadataResponse: metadataResponse,
                    tokenPrices: tokenPrices
                )
                balances.append(token)
            }
            
            let sortedBalances = balances.sorted(by: compareTokensByPrice)
            
            DispatchQueue.main.async {
                self.tokenBalances = sortedBalances
            }
        } catch {
            debugOutput("\(#function) error \(error)")
        }
    }
    
    // Получение токенов по владельцу
    func getTokenAccountsByOwner() async throws ->  [TokenAccount<TokenAccountState>] {
        let tokenProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
        
        return try await solanaAPIClient.getTokenAccountsByOwner(
            pubkey: publicKey,
            params: OwnerInfoParams(mint: nil, programId: tokenProgramId),
            configs: RequestConfiguration(encoding: "base64")
        )
    }
    
    // Получение метаданных токенов
    func getTokenMetadata(tokenAccounts: [TokenAccount<TokenAccountState>]) async throws -> [TokenMetadata] {
        let mintAddresses = tokenAccounts.map { $0.account.data.mint.base58EncodedString }
        
        return try await withCheckedThrowingContinuation { continuation in
            radiumAPI.getTokensMetadata(mintAddresses: mintAddresses) { result in
                switch result {
                case .success(let metadata):
                    continuation.resume(returning: metadata)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Получение цен токенов
    func getTokenPrices() async throws -> [String: Double] {
        return try await withCheckedThrowingContinuation { continuation in
            radiumAPI.getTokenPrices { result in
                switch result {
                case .success(let prices):
                    continuation.resume(returning: prices)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    
    // Функция для получения информации о токене
    func getTokenInfo(
        tokenAccount: TokenAccount<TokenAccountState>,
        metadataResponse: [TokenMetadata],
        tokenPrices: [String: Double]
    ) async throws -> SolToken {

        let pubkey = tokenAccount.pubkey
        let mintAddress = tokenAccount.account.data.mint.base58EncodedString
        let amount = tokenAccount.account.data.lamports
        let tokenMetadata = metadataResponse.first { $0.address == mintAddress }
        let price = tokenPrices[mintAddress]
        
        var token = SolToken(tokenAccount: pubkey,
                             mint: mintAddress,
                             amount: amount,
                             tokenMetadata: tokenMetadata,
                             price: price)

        
        return token
    }
    
    func compareTokensByPrice(_ lhs: SolToken, _ rhs: SolToken) -> Bool {
        let lhsPrice = lhs.totalAmountPriceInUSD ?? 0
        let rhsPrice = rhs.totalAmountPriceInUSD ?? 0
        return lhsPrice < rhsPrice
    }
}

//MARK: - Create Wallet
extension HomeViewModel {
    
    func createWallet() {
        let keyPair = try! KeyPair()
        print("Address: \(keyPair.publicKey.base58EncodedString)")
        print("Private Key: \(keyPair.secretKey.toHexString())")
        
        publicKey = keyPair.publicKey.base58EncodedString
        secretKey = keyPair.secretKey.toHexString()
        saveToKeychain(account: keyPair)
    }
    
    func saveToKeychain(account: KeyPair)  {
        let secretKeyData = account.secretKey
        let publicKey = account.publicKey.base58EncodedString
        
        do {
            try keychain.set(secretKeyData, key: publicKey)
            print("Saved to Keychain")
        } catch {
            print("Error saving to Keychain: \(error)")
        }
    }
}

//tokenAccounts [
//    SolanaSwift.TokenAccount<SolanaSwift.TokenAccountState>(
//        pubkey: "4Zr4oZzHGNBLHhju9vkEUmRdM8rJyCoZvkfSyRJCcrQT",
//        account: SolanaSwift.BufferInfo<SolanaSwift.TokenAccountState>(
//            lamports: 2039280,
//            owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
//            data: SolanaSwift.TokenAccountState(
//                mint: 26KMQVgDUoB6rEfnJ51yAABWWJND8uMtpnQgsHQ64Udr,
//                owner: 71EbTGmXWHNjwstEwSvNhn6MEQWgYvXGSzzzHKQAKepi,
//                lamports: 110000000,
//                delegateOption: 0,
//                delegate: nil,
//                isInitialized: true,
//                isFrozen: false,
//                state: 1,
//                isNativeOption: 0,
//                rentExemptReserve: nil,
//                isNativeRaw: 0,
//                isNative: false,
//                delegatedAmount: 0,
//                closeAuthorityOption: 0,
//                closeAuthority: nil),
//            executable: false,
//            rentEpoch: 18446744073709551615)),
//    SolanaSwift.TokenAccount<SolanaSwift.TokenAccountState>(
//        pubkey: "66q4GvdEgcKbw3LXvEfvqiAV24o9nDR3LcMWjFHqJaAh",
//        account: SolanaSwift.BufferInfo<SolanaSwift.TokenAccountState>(
//            lamports: 2039280,
//            owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
//            data: SolanaSwift.TokenAccountState(
//                mint: BXEapawFFdP9iRv3LGhXC9kfRY91pevzpZnUqsmZpump,
//                owner: 71EbTGmXWHNjwstEwSvNhn6MEQWgYvXGSzzzHKQAKepi,
//                lamports: 32423802166,
//                delegateOption: 0,
//                delegate: nil,
//                isInitialized: true,
//                isFrozen: false, s
//                tate: 1,
//                isNativeOption: 0,
//                rentExemptReserve: nil,
//                isNativeRaw: 0,
//                isNative: false,
//                delegatedAmount: 0,
//                closeAuthorityOption: 0,
//                closeAuthority: nil),
//            executable: false,
//            rentEpoch: 18446744073709551615))]



//💔 metadataResponse [
//    TradeBro.TokenData(
//        chainId: 101,
//        address: "26KMQVgDUoB6rEfnJ51yAABWWJND8uMtpnQgsHQ64Udr",
//        programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
//        logoURI: "https://img-v1.raydium.io/icon/26KMQVgDUoB6rEfnJ51yAABWWJND8uMtpnQgsHQ64Udr.png",
//        symbol: "HAMMY",
//        name: "SAD HAMSTER",
//        decimals: 6,
//        tags: [],
//        extensions: [:],
//        price: nil),
//    TradeBro.TokenData(
//        chainId: 101,
//        address: "BXEapawFFdP9iRv3LGhXC9kfRY91pevzpZnUqsmZpump",
//        programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
//        logoURI: "https://img-v1.raydium.io/icon/BXEapawFFdP9iRv3LGhXC9kfRY91pevzpZnUqsmZpump.png", 
//        symbol: "DOXXED",
//        name: "DOXXED",
//        decimals: 6,
//        tags: [],
//        extensions: [:],
//        price: nil)]

//import SwiftUI
//import SolanaSwift
//import KeychainAccess
//
//final class HomeViewModel: ObservableObject {
//    @Published var publicKey: String = ""
//    @Published private var secretKey: String = ""
//
//    @Published var solBalance: Double?
//    @Published var tokenBalances: [SolToken] = []
//
//    let keychain = Keychain(service: "com.yourapp.service")
//
//    private let radiumAPI: RadiumClientAPIProvider
//
//    init(conteiner: DependencyContainer = .shared) {
//        radiumAPI = conteiner.resolve()
//        loadWallet()
//    }
//}
//
////MARK: - Wallet Loading
//extension HomeViewModel {
//    func loadWallet() {
//        if let savedPublicKey = keychain.allKeys().first,
//           let keyPair = loadFromKeychain(publicKey: savedPublicKey) {
//            DispatchQueue.main.async {
//                self.publicKey = keyPair.publicKey.base58EncodedString
//                self.secretKey = keyPair.secretKey.toHexString()
//            }
//        }
//    }
//
//    private func loadFromKeychain(publicKey: String) -> KeyPair? {
//        do {
//            if let secretKeyData = try keychain.getData(publicKey) {
//                return try KeyPair(secretKey: secretKeyData)
//            }
//        } catch {
//            print("Error loading from Keychain: \(error)")
//        }
//        return nil
//    }
//
//    private func updateWalletKeys(keyPair: KeyPair) {
//           DispatchQueue.main.async {
//               self.publicKey = keyPair.publicKey.base58EncodedString
//               self.secretKey = keyPair.secretKey.toHexString()
//           }
//       }
//}
//
////MARK: - Get Tokens
//extension HomeViewModel {
//    func getTokenBalances(publicKey: String) async {
//        await getSolBalance(publicKey: publicKey)
//        await getSplTokenBalances(accountPublicKey: publicKey)
//    }
//
//    func getSolBalance(publicKey: String) async {
//        do {
//            let endpoint = APIEndPoint(
//                address: "https://api.mainnet-beta.solana.com",
//                network: .mainnetBeta
//            )
//            let solanaAPIClient = JSONRPCAPIClient(endpoint: endpoint)
//            let balance = try await solanaAPIClient.getBalance(account: publicKey, commitment: "recent")
//
//            DispatchQueue.main.async {
//                self.solBalance = Double(balance) / 1000000000
//            }
//            print("Баланс SOL: \(balance) лампортов = \(solBalance ?? 0) SOL")
//        } catch {
//            print("Ошибка при получении баланса SOL: \(error)")
//        }
//    }
//
//    func getSplTokenBalances(accountPublicKey: String) async  {
//        let endpoint = APIEndPoint(
//            address: "https://api.mainnet-beta.solana.com",
//            network: .mainnetBeta
//        )
//        let solanaAPIClient = JSONRPCAPIClient(endpoint: endpoint)
//
//        do {
//
//            let tokenProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
//
//            let tokenAccounts = try await solanaAPIClient.getTokenAccountsByOwner(
//                pubkey: accountPublicKey,
//                params: OwnerInfoParams(mint: nil, programId: tokenProgramId),
//                configs: RequestConfiguration(encoding: "base64")
//            )
//
//            var balances: [SolToken] = []
//
//            let mintAddresses = tokenAccounts.map { $0.account.data.mint.base58EncodedString }
//
//            let metadataResponse = try await withCheckedThrowingContinuation { continuation in
//                radiumAPI.getTokensMetadata(mintAddresses: mintAddresses) { result in
//                    switch result {
//                    case .success(let metadata):
//                        continuation.resume(returning: metadata)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//
//            let tokenPrices = try await withCheckedThrowingContinuation { continuation in
//                radiumAPI.getTokenPrices { result in
//                    switch result {
//                    case .success(let prices):
//                        continuation.resume(returning: prices)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//
//            for tokenAccount in tokenAccounts {
//                let tokenBalance = try await solanaAPIClient.getTokenAccountBalance(pubkey: tokenAccount.pubkey, commitment: "recent")
//
//                let mintAddress = tokenAccount.account.data.mint.base58EncodedString
//                let amount = Double(tokenBalance.amount) ?? 0
//
//                let tokenData = metadataResponse.first { $0.address == mintAddress }
//                var token = SolToken(mint: mintAddress, amount: amount, tokenData: tokenData)
//
//                if tokenData != nil {
//                    token.tokenData?.price = tokenPrices[mintAddress]
//                }
//
//                balances.append(token)
//            }
//
//            let sortedBalances = balances.sorted { $0.totalAmountPriceInUSD < $1.totalAmountPriceInUSD }
//            DispatchQueue.main.async {
//                self.tokenBalances = sortedBalances
//            }
//        } catch {
//            debugOutput("\(#function) error \(error)")
//        }
//    }
//}
//
////MARK: - Create Wallet
//extension HomeViewModel {
//
//    func createWallet() {
//        let keyPair = try! KeyPair()
//        print("Address: \(keyPair.publicKey.base58EncodedString)")
//        print("Private Key: \(keyPair.secretKey.toHexString())")
//
//        publicKey = keyPair.publicKey.base58EncodedString
//        secretKey = keyPair.secretKey.toHexString()
//        saveToKeychain(account: keyPair)
//    }
//
//    func saveToKeychain(account: KeyPair)  {
//        let secretKeyData = account.secretKey
//        let publicKey = account.publicKey.base58EncodedString
//
//        do {
//            try keychain.set(secretKeyData, key: publicKey)
//            print("Saved to Keychain")
//        } catch {
//            print("Error saving to Keychain: \(error)")
//        }
//    }
//}
