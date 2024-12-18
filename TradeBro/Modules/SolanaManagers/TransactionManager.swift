import SolanaSwift

protocol TransactionManagerProvider {
    func sendNativeSOL(from keyPair: KeyPair, to sentSolToAddress: String, amount sentSolAmount: UInt64) async
    func sendSPLTokens(from keyPair: KeyPair, sentToken: SolToken?, to sentTokenToAddress: String, amount sentTokenAmount: String) async
}

struct TransactionManager: BaseSolanaProvider {
    private var blockchainClient: BlockchainClient {
        BlockchainClient(apiClient: solanaAPIClient)
    }
}

// MARK: - Send Transactions
extension TransactionManager: TransactionManagerProvider {
    func sendNativeSOL(from keyPair: KeyPair, to sentSolToAddress: String, amount sentSolAmount: UInt64) async {
        do {
            let preparedTransaction = try await blockchainClient.prepareSendingNativeSOL(
                from: keyPair, to: sentSolToAddress, amount: sentSolAmount
            )
            
            let signature = try await blockchainClient.sendTransaction(
                preparedTransaction: preparedTransaction
            )
            debugOutput("Transaction successful: \(signature)")
        } catch {
            debugOutput("Transaction failed: \(error.localizedDescription)")
        }
    }
    
    func sendSPLTokens(from keyPair: KeyPair, sentToken: SolToken?, to sentTokenToAddress: String, amount sentTokenAmount: String) async {
        guard let sentToken, !sentTokenToAddress.isEmpty, !sentTokenAmount.isEmpty else {
            debugOutput("Invalid token or address")
            return
        }
        
        guard let amount = UInt64(sentTokenAmount) else {
            debugOutput("Invalid amount format")
            return
        }
        
        do {
            let tokenProgramId = try PublicKey(string: tokenProgramId)
            let lamportsPerSignature = try await getLamportsPerSignature()
            let minRentExemption = try await getMinRentExemption()
            
            let preparedTransaction = try await blockchainClient.prepareSendingSPLTokens(
                account: keyPair,
                mintAddress: sentToken.mint,
                tokenProgramId: tokenProgramId,
                decimals: sentToken.tokenMetadata?.decimals ?? 6,
                from: sentToken.tokenAccount,
                to: sentTokenToAddress,
                amount: amount * 1_000_000,
                lamportsPerSignature: lamportsPerSignature,
                minRentExemption: minRentExemption
            )
            
            debugOutput("Prepared Transaction: mintAddress \(sentToken.mint), decimals \(sentToken.tokenMetadata?.decimals ?? 6), from \(sentToken.tokenAccount), to: \(sentTokenToAddress), amount: \(amount), lamportsPerSignature: \(lamportsPerSignature), minRentExemption: \(minRentExemption)")
                  
            let signature = try await blockchainClient.sendTransaction(
                preparedTransaction: preparedTransaction.preparedTransaction
            )
            
            debugOutput("Transaction successful: \(signature)")
        } catch {
            debugOutput("Transaction failed: \(error.localizedDescription)")
        }
    }
    
    func getLamportsPerSignature() async throws -> UInt64 {
        let feesResponse = try await solanaAPIClient.getFees(commitment: "finalized")
        return feesResponse.feeCalculator?.lamportsPerSignature ?? 500
    }
    
    func getMinRentExemption() async throws -> UInt64 {
        let requiredDataLength: UInt64 = 165 // стандартное значение для токен-аккаунта
        return try await solanaAPIClient.getMinimumBalanceForRentExemption(dataLength: requiredDataLength)
    }
}
