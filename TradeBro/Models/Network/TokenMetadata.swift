struct TokenMetadata: Decodable {
    let chainId: Int
    let address: String
    let programId: String
    let logoURI: String
    let symbol: String
    let name: String
    let decimals: UInt8
    let tags: [String]
    let extensions: [String: String]
    let price: Double?
}

extension TokenMetadata {
    var mint: String {
        self.address
    }
}
