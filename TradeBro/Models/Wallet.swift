import Foundation
import SolanaSwift

struct Wallet: Identifiable {
    let id = UUID()
    let keyPair: KeyPair
    var name: String?
    
    var displayName: String {
        name ?? keyPair.publicKey.base58EncodedString 
    }
}
