import Foundation

protocol UserDefaultsProvider {
    func saveLastActiveWalletPublicKey(_ walletID: String)
    func loadLastActiveWalletPublicKey() -> String?
}

struct UserDefaultsManager: UserDefaultsProvider {
    private let lastWalletKey = "lastActiveWalletPublicKey"
    
    func saveLastActiveWalletPublicKey(_ walletID: String) {
        UserDefaults.standard.set(walletID, forKey: lastWalletKey)
    }
    
    func loadLastActiveWalletPublicKey() -> String? {
        return UserDefaults.standard.string(forKey: lastWalletKey)
    }
}
