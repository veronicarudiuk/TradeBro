import SwiftUI
import Combine

struct TokenView: View {
    @StateObject private var viewModel: TokenViewModel
    
    init(info: SolToken) {
        _viewModel = StateObject(wrappedValue: TokenViewModel(info: info))
    }
    
    var body: some View {
        Text("Mint: \(viewModel.token.mint)")
        HStack() {
            KFImageView(urlString: viewModel.token.tokenMetadata?.logoURI)
                .frame(width: 50,
                       height: 50)
                .padding()
            
            VStack(alignment: .leading) {
                Text("\(viewModel.token.tokenMetadata?.name ?? "-")")
                HStack() {
                    Text("\(viewModel.token.realAmount)")
                    Text("\(viewModel.token.tokenMetadata?.symbol ?? "-")")
                }
            }
            
            VStack(alignment: .leading) {
                Text("Total: $\(viewModel.token.totalAmountPriceInUSDString)")
                Text("Token price: $\(viewModel.token.priceString)")
            }
        }
    }
}
