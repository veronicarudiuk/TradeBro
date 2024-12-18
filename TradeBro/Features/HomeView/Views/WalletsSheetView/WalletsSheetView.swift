import SwiftUI
import Combine

struct WalletsSheetView: View {
    let wallets: [Wallet]
    let switchToWalletSubject: PassthroughSubject<Wallet, Never>
    let addedWalletSubject: PassthroughSubject<Wallet, Never>
    @Binding var isWalletsSheetVisible: Bool
    @State var isConnectWalletVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            top
            
            title
            
            walletsList
        }
        .setBGColor()
    }
}

// MARK: - Top
extension WalletsSheetView {
    var top: some View {
        VStack(spacing: 0) {
            divider
            
            HStack(spacing: 0) {
                close
                Spacer()
                add
            }
        }
    }
    
    var divider: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .foregroundStyle(.textMiddle)
            .frame(width: 36, height: 5)
            .padding(.top, 5)
    }
    
    var close: some View {
        Button(action: {
            isWalletsSheetVisible = false
        }) {
            Image(.delete)
                .frame(width: 20, height: 20)
                .padding(AppSizes.w16.value)
        }
    }
    
    var add: some View {
        Button(action: {
            isConnectWalletVisible = true
        }) {
            Image(.add)
                .frame(width: 20, height: 20)
                .padding(AppSizes.w16.value)
        }
        .sheet(isPresented: $isConnectWalletVisible) {
            ConnectWalletView(addedWalletSubject: addedWalletSubject)
        }
    }
    
    var title: some View {
        Text(main: .wallets)
            .foregroundStyle(.textDark)
            .font(.superLargeTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 3)
            .padding(.bottom, 8)
            .setMainHorizontalPadding()
    }
}

// MARK: - Wallets
extension WalletsSheetView {
    var walletsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(wallets) { wallet in
                WalletsSheetCellView(wallet: wallet)
                    .onTapGesture {
                        switchToWalletSubject.send(wallet)
                    }
            }
            .padding(.vertical, 24)
        }
        .setMainHorizontalPadding()
    }
}
