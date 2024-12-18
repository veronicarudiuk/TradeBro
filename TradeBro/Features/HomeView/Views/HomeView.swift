import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        VStack {
            top
            
            wallet
        }
    }
}

// MARK: - Top
extension HomeView {
    private var top: some View {
        HStack(spacing: 0) {
            Spacer()
            topWalletName
            Spacer()
        }
        .padding(.vertical, 14)
    }
    
    @ViewBuilder
    private var topWalletName: some View {
        if let activeWallet = viewModel.activeWallet {
            HStack(spacing: 0) {
                Text(activeWallet.displayName)
                    .foregroundStyle(.textDark)
                    .font(.body2Bold)
                    .padding(.trailing, 8)
                
                Image(.arrowDown)
                    .frame(width: 16, height: 16)
                
            }
            .onTapGesture {
                withAnimation {
                    viewModel.isWalletsSheetVisible.toggle()
                }
            }
            .sheet(isPresented: $viewModel.isWalletsSheetVisible) {
                WalletsSheetView(wallets: viewModel.wallets,
                                 switchToWalletSubject: viewModel.switchToWalletSubject,
                                 addedWalletSubject: viewModel.addedWalletSubject, 
                                 isWalletsSheetVisible: $viewModel.isWalletsSheetVisible)
            }
        } else {
            Spacer()
        }
    }
}
    

// MARK: - Top
extension HomeView {
    @ViewBuilder
    private var wallet: some View {
        if let activeWallet = viewModel.activeWallet {
            WalletView(wallet: activeWallet)
                .id(viewModel.activeWallet?.displayName)
        } else {
            addWallet
        }
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

