import SwiftUI
import Combine

struct ConnectWalletView: View {
    @StateObject private var viewModel: ConnectWalletViewModel
    
    init(addedWalletSubject: PassthroughSubject<Wallet, Never>) {
        _viewModel = StateObject(wrappedValue: ConnectWalletViewModel(addedWalletSubject: addedWalletSubject))
    }
    
    var body: some View {
        VStack {
            Text("Enter Private Key")
                .font(.headline)
            
            TextEditor(text: $viewModel.secretKey)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding()
            
            Button(action: {
                viewModel.addWallet()
            }) {
                Text("Connect")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
            
            
            Button(action: {
                viewModel.createWallet()
            }) {
                Text("Create new wallet")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()

    }
}
