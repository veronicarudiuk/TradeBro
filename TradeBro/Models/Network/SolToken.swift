struct SolToken {
    var tokenAccount: String
    var mint: String
    var amount: UInt64
    var tokenMetadata: TokenMetadata?
    var price: Double?
}

extension SolToken {
    var realAmount: Double {
        Double(amount / 1000000)
    }
    
    var totalAmountPriceInUSD: Double? {
        guard let price else { return nil }
        return realAmount * price
    }
    
    var totalAmountPriceInUSDString: String {
        guard let totalAmountPriceInUSD else { return "-" }
        return "\(totalAmountPriceInUSD)"
    }
    
    var priceString: String {
        guard let price = tokenMetadata?.price else { return "-" }
        return "\(price)"
    }
}
