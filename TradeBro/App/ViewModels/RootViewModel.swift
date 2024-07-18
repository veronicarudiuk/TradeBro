import SwiftUI
import Combine

final class RootViewModel: ObservableObject {
    enum CurrentViewType {
        case preloader
        case welcome
        case home
    }
    
    @Published private(set) var currentView: CurrentViewType
    @Published var refreshKey = UUID()
    
    
    private var ifNewUser: Bool {
        didSet {
            currentView = ifNewUser ? .welcome : .home
        }
    }
    
    let resetAppViews: PassthroughSubject<Void, Never>
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        DependencyContainer.registerClients()
        ifNewUser = false
        currentView = .preloader
        resetAppViews = PassthroughSubject<Void, Never>()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        resetAppViews
            .sink { [weak self] type in
                guard let self else { return }
                handleRealmChanges()
            }
            .store(in: &cancellables)
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
    
    private func handleRealmChanges() {
        checkIfUserIsNew()
        refreshKey = UUID()
    }
}
