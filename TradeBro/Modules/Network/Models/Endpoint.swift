import Foundation

struct Endpoint {
    
    //MARK: - instance
    let path: String
    let queryItems: [URLQueryItem]
}

//MARK: - URL
extension Endpoint {
    
    var urlRaydiumAPI: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.raydium.io"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
    
    var urlRaydiumV3API: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-v3.raydium.io"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }

}

extension Endpoint {
    
    //MARK: - nested enums
    enum Path {
        case price,
             metadata
        
        var rawValue: String {
            switch self {
            case .price:
                return "/v2/main/price"
            case .metadata:
                return "/mint/ids"
            }
        }
    }
    
    enum Query {
        case mints(String)

        var name: String {
            switch self {
            case .mints:
                return "mints"
            }
        }
        
        var value: String {
            switch self {
            case .mints(let mints):
                return mints
            }
        }
    }
}

