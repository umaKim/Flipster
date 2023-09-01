//
//  MockData.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//
import Models
import Foundation

public enum MockData {
    public static let crypto = CoinCapAsset(
        id: "bitcoin",
        symbol: "btc",
        name: "Bitcoin",
        image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
        currentPrice: 2251581,
        marketCapRank: 43856865800037,
        marketCap: 1,
        fullyDilutedValuation: 47298160593254,
        totalVolume: 1075173186877,
        high24H: 2272872,
        low24H: 2237562,
        priceChange24H: -18388.835470230784,
        priceChangePercentage24H: -0.81009,
        marketCapChange24H: -352322462896.8672,
        marketCapChangePercentage24H: -0.79694,
        circulatingSupply: 19472093,
        totalSupply: 21000000,
        maxSupply: 21000000,
        ath: 5128383,
        athChangePercentage: -56.06966,
        athDate: "2021-11-10T14:24:11.849Z",
        atl: 3993.42,
        atlChangePercentage: 56315.70551,
        atlDate: "2013-07-05T00:00:00.000Z",
        lastUpdated: "2023-08-31T05:54:38.455Z",
        priceChangePercentage24HInCurrency: -0.8100915486594255
    )
    
    public static let chartData = ChartData(
        closePrice: [1],
        highPrice: [1],
        lowPrice: [1],
        openPrice: [1],
        time: [1],
        volume: [1]
    )
    
    public static let coinPriceData = WebSocketDatum(
        price: 7296.89,
        symbol: "BINANCE:BTCUSDT"
    )
    
    public static let wsRawData = "{\"data\":[{\"c\":null,\"p\":7296.89,\"s\":\"BINANCE:BTCUSDT\",\"t\":1693504334843,\"v\":50}],\"type\":\"trade\"}"
}
