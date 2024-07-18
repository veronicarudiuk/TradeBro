import SwiftUI

//MARK: - Navigation
extension View {
    func hideNavigationBar() -> some View {
        self
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func commonModifiers() -> some View {
        self
            .hideNavigationBar()
            .ignoresSafeArea(.keyboard)
            .ignoresSafeArea(.all)
    }
}

