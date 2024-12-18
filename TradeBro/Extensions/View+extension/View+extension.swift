import SwiftUI

extension View {
    func setMainHorizontalPadding() -> some View {
        self
            .padding(.horizontal, AppSizes.w16.value)
    }
    
    func setBGColor() -> some View {
        self
            .background(Color.bgWhite.edgesIgnoringSafeArea(.all))
    }
}

