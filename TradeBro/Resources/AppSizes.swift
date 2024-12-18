import SwiftUI

enum AppSizes {
    case
    screenWidth,
    screenHeight,
    
    gridCardWidth,
    gridCardHeight,
    
    h24,
    h12,
    h4,
    
    w16,
    w8,
    w3
    
    var value: CGFloat {
        switch self {
        case .screenWidth:
            return screenWidth
        case .screenHeight:
            return screenHeight
            
        case .gridCardWidth:
            return (AppSizes.screenWidth.value - AppSizes.w16.value - AppSizes.w3.value) / 2
        case .gridCardHeight:
            return 150
         
        case .h24:
            return screenHeight * 0.028
        case .h12:
            return screenHeight * 0.014
        case .h4:
            return screenHeight * 0.004
            
        case .w16:
            return screenWidth * 0.04
        case .w8:
            return screenWidth * 0.02
        case .w3:
            return screenWidth * 0.0076
        }
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
}
