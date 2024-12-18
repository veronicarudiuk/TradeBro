import SwiftUI

extension Text {
    init(main: AppText.Main) {
        self.init(main.rawValue)
    }
}
