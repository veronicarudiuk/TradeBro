import SwiftUI

enum SFPro: String {
    case regular = "SF Pro Text Regular"
    case semibold = "SF Pro Text Semibold"
    
    var name : String {
        rawValue
    }
}

extension Font {
    
    //MARK: - stutic func
    private static func sfProDisplay(_ weight: Font.Weight?,
                                     size: CGFloat = 8) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    
    //MARK: - stutic instance
    static let superLargeTitle = sfProDisplay(.bold,
                                           size: 40)
    static let largeTitle = sfProDisplay(.bold,
                                           size: 32)
    static let largeTitle2 = sfProDisplay(.bold,
                                           size: 28)
    
    static let title1Regular = sfProDisplay(.regular,
                                           size: 24)
    static let title1Medium = sfProDisplay(.medium,
                                           size: 24)
    static let title1Bold = sfProDisplay(.bold,
                                           size: 24)
    
    static let title2Regular = sfProDisplay(.regular,
                                           size: 20)
    static let title2Medium = sfProDisplay(.medium,
                                           size: 20)
    static let title2Bold = sfProDisplay(.bold,
                                           size: 20)
    
    static let title3Regular = sfProDisplay(.regular,
                                           size: 18)
    static let title3Medium = sfProDisplay(.medium,
                                           size: 18)
    static let title3Bold = sfProDisplay(.bold,
                                           size: 18)
    
    static let body1Regular = sfProDisplay(.regular,
                                           size: 16)
    static let body1Medium = sfProDisplay(.medium,
                                           size: 16)
    static let body1Bold = sfProDisplay(.bold,
                                           size: 16)
    
    static let body2Regular = sfProDisplay(.regular,
                                           size: 14)
    static let body2Medium = sfProDisplay(.medium,
                                           size: 14)
    static let body2Bold = sfProDisplay(.bold,
                                           size: 14)
    
    static let body3Regular = sfProDisplay(.regular,
                                           size: 13)
    static let body3Medium = sfProDisplay(.medium,
                                           size: 13)
    static let body3Bold = sfProDisplay(.bold,
                                           size: 13)
    
    static let caption1Regular = sfProDisplay(.regular,
                                              size: 12)
    static let caption1Medium = sfProDisplay(.medium,
                                           size: 12)
    static let caption1Bold = sfProDisplay(.bold,
                                           size: 12)
    
    static let caption2Regular = sfProDisplay(.regular,
                                              size: 10)
    static let caption2Medium = sfProDisplay(.medium,
                                           size: 10)
    static let caption2Bold = sfProDisplay(.bold,
                                           size: 10)
}
