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
        debugOutput()
        
        let mintAddressesString = mintAddresses.joined(separator: ",")
        
        let endpoint = makeEndPoint(with: .metadata, and: [.mints(mintAddressesString)])
        
        guard let request = try? makeURLRequest(with: .raydiumV3(endpoint: endpoint), and: .GET) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.requestFailed))
            }
            return
        }
        
        cancelCurrentTask()
        
        currentTask = execute(request) { (result: Result<Response<RaydiumResponse>, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.value.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func getTokenPrices(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        debugOutput()
        
        let endpoint = makeEndPoint(with: .price, and: [])
        
        guard let request = try? makeURLRequest(with: .raydium(endpoint: endpoint), and: .GET) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.requestFailed))
            }
            return
        }
        
        cancelCurrentTask()
        
        currentTask = execute(request) { (result: Result<Response<[String: Double]>, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
