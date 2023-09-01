//
//  CoinCapAsset.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/23.
//

import Foundation

public struct CoinCapAsset: Codable, Identifiable, Equatable {
    public static func == (lhs: CoinCapAsset, rhs: CoinCapAsset) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id, symbol, name: String
    public let image: String
    public var currentPrice: Double
    public let marketCapRank: Int
    public let marketCap, fullyDilutedValuation: Double?
    public let totalVolume, high24H, low24H: Double?
    public let priceChange24H, priceChangePercentage24H: Double
    public let marketCapChange24H: Double?
    public let marketCapChangePercentage24H: Double?
    public let circulatingSupply, totalSupply, maxSupply, ath: Double?
    public let athChangePercentage: Double?
    public let athDate: String?
    public let atl, atlChangePercentage: Double?
    public let atlDate: String?
    public let lastUpdated: String?
    public let priceChangePercentage24HInCurrency: Double?
    
    public enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
    }
    
    public init(
        id: String,
        symbol: String,
        name: String,
        image: String,
        currentPrice: Double,
        marketCapRank: Int,
        marketCap: Double?,
        fullyDilutedValuation: Double?,
        totalVolume: Double?,
        high24H: Double?,
        low24H: Double?,
        priceChange24H: Double,
        priceChangePercentage24H: Double,
        marketCapChange24H: Double?,
        marketCapChangePercentage24H: Double?,
        circulatingSupply: Double?,
        totalSupply: Double?,
        maxSupply: Double?,
        ath: Double?,
        athChangePercentage: Double?,
        athDate: String?,
        atl: Double?,
        atlChangePercentage: Double?,
        atlDate: String?,
        lastUpdated: String?,
        priceChangePercentage24HInCurrency: Double?
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCapRank = marketCapRank
        self.marketCap = marketCap
        self.fullyDilutedValuation = fullyDilutedValuation
        self.totalVolume = totalVolume
        self.high24H = high24H
        self.low24H = low24H
        self.priceChange24H = priceChange24H
        self.priceChangePercentage24H = priceChangePercentage24H
        self.marketCapChange24H = marketCapChange24H
        self.marketCapChangePercentage24H = marketCapChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.ath = ath
        self.athChangePercentage = athChangePercentage
        self.athDate = athDate
        self.atl = atl
        self.atlChangePercentage = atlChangePercentage
        self.atlDate = atlDate
        self.lastUpdated = lastUpdated
        self.priceChangePercentage24HInCurrency = priceChangePercentage24HInCurrency
    }
}
