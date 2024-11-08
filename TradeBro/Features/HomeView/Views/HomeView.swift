import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        VStack {
            top
            
            if viewModel.isDropdownVisible {
                dropdown
            }
            
            if let activeWallet = viewModel.activeWallet {
                WalletView(wallet: activeWallet)
            }
            
            
                addWallet
            
        }
    }
    
    private var top: some View {
        HStack {
            Text(viewModel.activeWallet?.displayName ?? "No Wallet")
                .font(.title)
                .bold()
            Spacer()
            Button(action: {
                withAnimation {
                    viewModel.isDropdownVisible.toggle()
                }
            }) {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(viewModel.isDropdownVisible ? 180 : 0))
            }
        }
        .padding()
    }
    
    private var dropdown: some View {
        WalletDropdownView(wallets: viewModel.wallets, onSelect: { wallet in
            viewModel.switchWallet(to: wallet)
            withAnimation {
                viewModel.isDropdownVisible = false
            }
        })
    }
    
    private var addWallet: some View {
        Button(action: {
            viewModel.isConnectWalletVisible = true
        }) {
            Text("Connect Wallet")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .sheet(isPresented: $viewModel.isConnectWalletVisible) {
            ConnectWalletView(addedWalletSubject: viewModel.addedWalletSubject)
        }
    }
}

