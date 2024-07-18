import SwiftUI

struct PreloaderView: View {
    
    var body: some View {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.textDark)
                        .frame(width: 123, height: 123)
                    
                    Spacer()
                }
                
                Spacer()
            }
        .background(.bgSuperLight)
    }
}

struct PreloaderView_Previews: PreviewProvider {
    static var previews: some View {
        PreloaderView()
    }
}
