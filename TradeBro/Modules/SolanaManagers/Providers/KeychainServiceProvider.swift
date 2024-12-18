import KeychainAccess

protocol KeychainServiceProvider {
    var keychainService: String { get }
    var keychain: KeychainAccess.Keychain { get }
}

extension KeychainServiceProvider {
    var keychainService: String {
        "com.tradeBro.service"
    }
    
    var keychain: KeychainAccess.Keychain {
        KeychainAccess.Keychain(service: keychainService)
    }
}
