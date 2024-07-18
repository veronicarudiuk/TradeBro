import Foundation

// MARK: - protocol API client
protocol APIClient {
    var session: URLSession { get }
    func execute<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<Response<T>, Error>) -> Void)
}

extension APIClient {
    
    func execute<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                debugOutput(error)
                completion(.failure(NetworkError.transportError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data,
                  200..<300 ~= httpResponse.statusCode else {
                let statusCode = (response as! HTTPURLResponse).statusCode
                switch statusCode {
                case 400...499:
                    completion(.failure(NetworkError.validationError(String(statusCode))))
                default:
                    completion(.failure(NetworkError.serverError))
                }
                return
            }
            
            let result: Result<T, Error> = decodeData(T.self, from: data)
            switch result {
            case .success(let value):
                completion(.success(Response(value: value, response: httpResponse)))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
}

extension APIClient {
    
    func decodeData<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            debugOutput("Decoding error: \(error)")
            debugOutput("Decoding error localized description: \(error.localizedDescription)")
            
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    debugOutput("Key not found: \(key.stringValue)")
                case .typeMismatch(let type, let context):
                    debugOutput("Type mismatch: \(type), context: \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    debugOutput("Value not found: \(value), context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    debugOutput("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    debugOutput("Unknown decoding error")
                }
            }
            
            return .failure(error)
        }
    }
}

extension APIClient {
    
    //MARK: - end point and request
    func makeEndPoint(with path: Endpoint.Path,
                      and queries: [Endpoint.Query]) -> Endpoint {
        var queryItems : [URLQueryItem] = []
        
        queries.forEach {
            let queryItem : URLQueryItem = .init(name: $0.name,
                                                 value: $0.value)
            queryItems.append(queryItem)
        }
        
        return Endpoint(path: path.rawValue,
                        queryItems: queryItems)
    }
    
    func makeURLRequest(with apiType: APIType,
                        and httpMethod: HTTPMethod) throws -> URLRequest {
        guard let url = apiType.url else { throw NetworkError.linkError }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = apiType.httpHeader
        request.httpMethod = httpMethod.rawValue
        request.networkServiceType = .responsiveData
        
        return request
    }
}

//MARK: - httpMethod
enum HTTPMethod: String {
    case GET
    
    var rawValue: String {
        switch self {
        case .GET:
            return "GET"
        }
    }
}

enum APIType {
    case raydium (endpoint: Endpoint)
   
    var url : URL? {
        switch self {
        case .raydium(let endpoint):
            let url = endpoint.urlRaydiumAPI
            return url
        }
    }
    
    var httpHeader : [String : String]? {
//        switch self {
//        case .transfermarket:
//            ["X-RapidAPI-Key": "0a4b43d9f6mshc9e9d6270843362p1bd519jsnd1c97f754415"]
//        case .newsAPI:
            nil
//        }
    }
}
