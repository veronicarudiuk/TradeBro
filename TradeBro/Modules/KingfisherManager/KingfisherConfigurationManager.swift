import Kingfisher

protocol KingfisherConfigurationProvider {
    func configure()
}

struct KingfisherConfigurationManager: KingfisherConfigurationProvider {
    
    init() {
        configure()
    }
    
    func configure() {
        KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 100
    }
}
