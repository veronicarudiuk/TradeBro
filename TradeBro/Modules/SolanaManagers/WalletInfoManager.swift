import Foundation
import SolanaSwift

protocol WalletInfoManagerProvider {
    func getTokenBalances(for publicKey: String) async throws -> (solBalance: Double, tokenBalances: [SolToken])
}

struct WalletInfoManager: BaseSolanaProvider {
    private let radiumAPI: RadiumClientAPIProvider
    
    init(container: DependencyContainer = .shared) {
        radiumAPI = container.resolve()
    }
}

// MARK: - Get Tokens
extension WalletInfoManager: WalletInfoManagerProvider {
    func getTokenBalances(for publicKey: String) async throws -> (solBalance: Double, tokenBalances: [SolToken]) {
        let solBalance = try await getSolBalance(for: publicKey)
        let tokenBalances = try await getSplTokenBalances(for: publicKey)
        return (solBalance, tokenBalances)
    }
    
    // Баланс SOL
    private func getSolBalance(for publicKey: String) async throws -> Double {
        do {
            let balance = try await solanaAPIClient.getBalance(account: publicKey, commitment: "recent")
            let solBalance = Double(balance) / 1000000000
            debugOutput("Баланс SOL: \(balance) лампортов = \(solBalance) SOL")
            return solBalance
        } catch {
            throw NSError(domain: "WalletInfoManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка при получении баланса SOL: \(error)"])
        }
    }
    
    // Баланс токенов
    private func getSplTokenBalances(for publicKey: String) async throws -> [SolToken] {
        do {
            var balances: [SolToken] = []
            let tokenAccounts = try await getTokenAccountsByOwner(for: publicKey)
            let metadataResponse = try await getTokenMetadata(tokenAccounts: tokenAccounts)
            let tokenPrices = try await getTokenPrices()
            
            for tokenAccount in tokenAccounts {
                let token = try await getTokenInfo(
                    tokenAccount: tokenAccount,
                    metadataResponse: metadataResponse,
                    tokenPrices: tokenPrices
                )
                balances.append(token)
            }
            return balances.sorted(by: compareTokensByPrice)
        } catch {
            throw NSError(domain: "WalletInfoManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Ошибка при получении баланса токенов: \(error)"])
        }
    }
    
    // Получение токенов по владельцу
    private func getTokenAccountsByOwner(for publicKey: String) async throws -> [TokenAccount<TokenAccountState>] {
        try await solanaAPIClient.getTokenAccountsByOwner(
            pubkey: publicKey,
            params: OwnerInfoParams(mint: nil, programId: tokenProgramId),
            configs: RequestConfiguration(encoding: "base64")
        )
    }
    
    // Получение метаданных токенов
    private func getTokenMetadata(tokenAccounts: [TokenAccount<TokenAccountState>]) async throws -> [TokenMetadata] {
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
    private func getTokenPrices() async throws -> [String: Double] {
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
    
    // Получение информации о токене
    private func getTokenInfo(
        tokenAccount: TokenAccount<TokenAccountState>,
        metadataResponse: [TokenMetadata],
        tokenPrices: [String: Double]
    ) async throws -> SolToken {

        let pubkey = tokenAccount.pubkey
        let mintAddress = tokenAccount.account.data.mint.base58EncodedString
        let amount = tokenAccount.account.data.lamports
        let tokenMetadata = metadataResponse.first { $0.address == mintAddress }
        let price = tokenPrices[mintAddress]
        
        let token = SolToken(tokenAccount: pubkey,
                             mint: mintAddress,
                             amount: amount,
                             tokenMetadata: tokenMetadata,
                             price: price)
        return token
    }
    
    private func compareTokensByPrice(_ lhs: SolToken, _ rhs: SolToken) -> Bool {
        let lhsPrice = lhs.totalAmountPriceInUSD ?? 0
        let rhsPrice = rhs.totalAmountPriceInUSD ?? 0
        return lhsPrice < rhsPrice
    }
}
