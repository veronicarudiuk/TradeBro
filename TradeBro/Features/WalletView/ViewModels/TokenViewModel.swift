import SwiftUI

final class TokenViewModel: ObservableObject {
    let token: SolToken
    
    init(info: SolToken) {
        self.token = info
    }
}
    
