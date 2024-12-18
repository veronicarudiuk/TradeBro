import SwiftUI

final class RootViewModel: ObservableObject {
    enum CurrentViewType {
        case preloader
        case welcome
        case home
    }
    
    @Published private(set) var currentView: CurrentViewType

    private var ifNewUser: Bool {
        didSet {
            currentView = ifNewUser ? .welcome : .home
        }
    }
    
    init() {
        DependencyContainer.registerClients()
        ifNewUser = false
        currentView = .preloader
    }
    
    func loadInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in //!! изменить на 3
            guard let self else { return }
            checkIfUserIsNew()
        }
    }
    
    private func checkIfUserIsNew() {
        ifNewUser = false
//        ifNewUser = realmManager.initializeDatabase()
    }
}
