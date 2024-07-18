import SwiftUI
//import Combine

enum AppRouter {
    case preloader
    case welcome//(PassthroughSubject<Void, Never>)
    case home

    
    var view: some View {
        Group {
            switch self {
            case .preloader:
                PreloaderView()
            case .welcome:
                WelcomeView()
            case .home:
                HomeView()
            }
        }
        .commonModifiers()
    }
}
