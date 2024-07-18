import Foundation

protocol RadiumClientAPIProvider {
    func getTokensMetadata(mintAddresses: [String],
                           completion: @escaping (Result<[TokenMetadata], Error>) -> Void)
    func getTokenPrices(completion: @escaping (Result<[String: Double], Error>) -> Void)
}

final class RadiumClientAPI: APIClient {
    
    //MARK: - instance
    let session: URLSession
    
    private var currentTask: URLSessionDataTask?
    
    //MARK: - initialization
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral) {
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.networkServiceType = .responsiveData
        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .ephemeral)
    }
}

extension RadiumClientAPI: RadiumClientAPIProvider {
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func getTokensMetadata(mintAddresses: [String],
                           completion: @escaping (Result<[TokenMetadata], Error>) -> Void) {
        debugOutput("start \(#function) mintAddresses \(mintAddresses)")
        cancelCurrentTask()
        
        let mintAddressesString = mintAddresses.joined(separator: ",")
        
        let endpoint = "https://api-v3.raydium.io/mint/ids?mints=\(mintAddressesString)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        currentTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode(RaydiumResponse.self, from: data)
                DispatchQueue.main.async {
                    let tokenDatas = responseModel.data
                    completion(.success(tokenDatas))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
    
    
    func getTokenPrices(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        debugOutput("start \(#function)")
        cancelCurrentTask()
        
        let endpoint = makeEndPoint(with: .price, and: [])
        
        guard let request = try? makeURLRequest(with: .raydium(endpoint: endpoint), and: .GET) else {
            completion(.failure(NetworkError.requestFailed))
            return
        }
        
        currentTask = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                debugOutput("\(#function) error \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode([String: Double].self, from: data)
                completion(.success(responseModel))
            } catch {
                completion(.failure(error))
            }
        }
        currentTask?.resume()
    }
}
