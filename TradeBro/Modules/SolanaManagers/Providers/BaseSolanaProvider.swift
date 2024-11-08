import SolanaSwift

protocol BaseSolanaProvider {
    var endpoint: APIEndPoint { get }
    var solanaAPIClient: JSONRPCAPIClient { get }
    var tokenProgramId: String { get }
}

extension BaseSolanaProvider {
    var endpoint: APIEndPoint {
        APIEndPoint(
            address: "https://api.mainnet-beta.solana.com",
            network: .mainnetBeta
        )
    }
    
    var solanaAPIClient: JSONRPCAPIClient {
        JSONRPCAPIClient(endpoint: endpoint)
    }
    
    var tokenProgramId: String {
        "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    }
}
