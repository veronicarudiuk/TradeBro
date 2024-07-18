import Foundation

struct Response<T> {
    
    //MARK: - instance
    let value: T
    let response: URLResponse
}

struct RaydiumResponse: Decodable {
    let id: String
    let success: Bool
    let data: [TokenMetadata]
}

struct TokenPriceResponse: Decodable {
    let prices: [String: Double]
}
