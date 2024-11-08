import Foundation
import SolanaSwift

struct RadiumAPI {
    let apiKey: String
    let baseURL = "https://api.radium.io/v1"
    
    func getMarketData(pair: String, completion: @escaping (Result<MarketData, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/markets/\(pair)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let marketData = try JSONDecoder().decode(MarketData.self, from: data)
                completion(.success(marketData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func buyToken(wallet: KeyPair, amount: Double, completion: @escaping (Result<TransactionResult, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let order = Order(walletAddress: wallet.publicKey.base58EncodedString, amount: amount)
        do {
            request.httpBody = try JSONEncoder().encode(order)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TransactionResult.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
}

struct MarketData: Codable {
    let pair: String
    let price: Double
}

struct Order: Codable {
    let walletAddress: String
    let amount: Double
}

struct TransactionResult: Codable {
    let success: Bool
    let message: String
}
