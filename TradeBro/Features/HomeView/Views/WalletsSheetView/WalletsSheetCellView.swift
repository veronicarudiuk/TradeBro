import SwiftUI

struct WalletsSheetCellView: View {
    let wallet: Wallet
    
    var body: some View {
        HStack(spacing: 0) {
            leftSide
            
            Spacer()
            
            rightSide
        }
        .setMainHorizontalPadding()
        .frame(height: 74)
        .background(.bgSuperLight)
        .cornerRadius(16)
    }
}

// MARK: - Left side
extension WalletsSheetCellView {
    var leftSide: some View {
        VStack(spacing: 8) {
            title
            
            HStack(spacing: 4) {
                balance
                divider
                balanceChange
                Spacer()
            }
        }
    }
    
    var title: some View {
        Text(wallet.displayName)
            .foregroundStyle(.textDark)
            .font(.title3Bold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var balance: some View {
        Text("\(wallet.currentBalance ?? 23.10)")
            .foregroundStyle(.textDark)
            .font(.caption1Medium)
    }
    
    var balanceChange: some View {
        let balanceChangeAmount = wallet.balanceChangeAmount ?? -13.60
        return Text("\(balanceChangeAmount)")
            .foregroundStyle(balanceChangeAmount < 0 ? .redSecondary : .greenMain)
            .font(.caption1Medium)
    }
    
    var divider: some View {
        Divider()
            .foregroundStyle(.bgDark)
            .frame(width: 1, height: 8, alignment: .center)
    }
}

// MARK: - Right side
extension WalletsSheetCellView {
    var rightSide: some View {
        Image(.arrowRight)
            .frame(width: 24, height: 24)
    }
}
