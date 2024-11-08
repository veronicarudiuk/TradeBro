import SwiftUI

enum AppRouter {
    case preloader
    case welcome
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
