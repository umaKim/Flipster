//
//  ChartData.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//

import Foundation

public struct ChartData: Codable {
    public let closePrice: [Double]    // close price
    public let highPrice: [Double]     // high price
    public let lowPrice: [Double]      // low price
    public let openPrice: [Double]     // open price
    public let time: [Double]          // timestamp price
    public let volume: [Double]        // volume data
    
    public enum CodingKeys: String, CodingKey {
        case closePrice = "c"
        case highPrice = "h"
        case lowPrice = "l"
        case openPrice = "o"
        case time = "t"
        case volume = "v"
    }
    
    public init(
        closePrice: [Double],
        highPrice: [Double],
        lowPrice: [Double],
        openPrice: [Double],
        time: [Double],
        volume: [Double]
    ) {
        self.closePrice = closePrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.openPrice = openPrice
        self.time = time
        self.volume = volume
    }
}
