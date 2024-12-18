import Foundation
import SolanaSwift

struct Wallet: Identifiable {
    let id = UUID()
    let keyPair: KeyPair
    var name: String?
    var currentBalance: Double? //!!
    var balanceChangeAmount: Double? //!!
    
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        } else {
            let publicKey = keyPair.publicKey.base58EncodedString
            let start = publicKey.prefix(4)
            let end = publicKey.suffix(4)
            return "\(start)...\(end)"
        }
    }
}
