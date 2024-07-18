import SwiftUI

final class DependencyContainer {
    
    //MARK: - static instance
    public static var shared = DependencyContainer()
    
    //MARK: - instance
    private var services: [String: Any] = [:]
    
    //MARK: - container logic
    func register<T>(interface: T.Type,
                     service: T) {
        let key = String(describing: interface)
        services[key] = service
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        return services[key] as! T
    }

}

extension DependencyContainer {
    
    //MARK: - static func
    public static func registerClients() {
        shared.register(interface: KingfisherConfigurationProvider.self,
                                service: KingfisherConfigurationManager())
        
        shared.register(interface: RadiumClientAPIProvider.self,
                        service: RadiumClientAPI())

    }
}
