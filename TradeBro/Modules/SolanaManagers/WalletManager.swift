import Foundation
import Combine
import SolanaSwift

protocol WalletManagerProvider {
    var activeWallets: [Wallet] { get }
    var activeWalletsPublisher: AnyPublisher<[Wallet], Never> { get }
    func createWallet(name: String?) -> Wallet?
    func setWalletName(for publicKey: String, name: String)
    func addWallet(secretKey: String, name: String?) -> Wallet?
}

final class WalletManager: WalletManagerProvider, KeychainServiceProvider {
    @Published var activeWallets: [Wallet]
    var activeWalletsPublisher: AnyPublisher<[Wallet], Never> { $activeWallets.eraseToAnyPublisher() }
    
    init() {
        activeWallets = []
        updateActiveWallets()
    }
    
    private func updateActiveWallets() {
        loadAllWallets()
    }
}

extension WalletManager {
    // MARK: - Wallet Loading (Combined)
    private func loadWallet(for publicKey: String) -> Wallet? {
        debugOutput()
        guard let keyPair = loadKeyPair(for: publicKey) else {
            debugOutput()
            return nil
        }
        let name = loadName(for: publicKey)
        return Wallet(keyPair: keyPair, name: name)
    }
    
    // MARK: - KeyPair Loading
    private func loadKeyPair(for publicKey: String) -> KeyPair? {
        do {
            if let secretKeyData = try keychain.getData(publicKey) {
                return try KeyPair(secretKey: secretKeyData)
            }
        } catch {
            debugOutput("Error loading KeyPair from Keychain: \(error)")
        }
        return nil
    }
    
    // MARK: - Wallet Name Loading
    private func loadName(for publicKey: String) -> String? {
        do {
            return try keychain.get("\(publicKey)_name")
        } catch {
            debugOutput("Error loading wallet name from Keychain: \(error)")
            return nil
        }
    }
    
    // MARK: - Loading All Wallets
    private func loadAllWallets() {
        var wallets: [Wallet] = []
        debugOutput(keychain.allKeys())
        for key in keychain.allKeys() {
            if !key.contains("_name"), let wallet = loadWallet(for: key) {
                wallets.append(wallet)
            }
        }
        activeWallets = wallets
        debugOutput(activeWallets.count)
    }
}

extension WalletManager {
    // MARK: - Combined Wallet Creation
    func createWallet(name: String?) -> Wallet? {
        guard let keyPair = createKeyPair() else { return nil }
        if let name = name {
            setWalletName(for: keyPair.publicKey.base58EncodedString, name: name)
        }
        
        return Wallet(keyPair: keyPair, name: name)
    }
    
    // MARK: - KeyPair Creation
    private func createKeyPair() -> KeyPair? {
        do {
            let keyPair = try KeyPair()
            setWalletKeyPair(for: keyPair)
            debugOutput("Created KeyPair: \(keyPair.publicKey.base58EncodedString)")
            return keyPair
        } catch {
            debugOutput("Error creating KeyPair: \(error)")
            return nil
        }
    }
    
    private func setWalletKeyPair(for keyPair: KeyPair) {
        do {
            try keychain.set(keyPair.secretKey, key: keyPair.publicKey.base58EncodedString)
            debugOutput("Created KeyPair in Keychain: \(keyPair.publicKey.base58EncodedString)")
        } catch {
            debugOutput("Error creating KeyPair in Keychain: \(error)")
        }
    }
    
    // MARK: - Name Creation
    func setWalletName(for publicKey: String, name: String) {
        do {
            try keychain.set(name, key: "\(publicKey)_name")
            debugOutput("Created wallet name in Keychain: \(name)")
        } catch {
            debugOutput("Error creating wallet name in Keychain: \(error)")
        }
    }
    
    // MARK: - Add Wallet from Secret Key
    func addWallet(secretKey: String, name: String?) -> Wallet? {
        do {
            let secretKeyData = Data(Base58.decode(secretKey))
            let keyPair = try KeyPair(secretKey: secretKeyData)
            setWalletKeyPair(for: keyPair)
            
            if let name = name {
                setWalletName(for: keyPair.publicKey.base58EncodedString, name: name)
            }
            
            return Wallet(keyPair: keyPair, name: name)
        } catch {
            debugOutput("Error creating wallet from secret: \(error)")
            return nil
        }
    }
}
