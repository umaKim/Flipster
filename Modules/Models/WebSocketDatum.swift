//
//  WebSocketDatum.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//

import Foundation

public struct WebSocketResponse : Decodable {
    public let webSocketData: [WebSocketDatum]
    
    public enum CodingKeys: String, CodingKey {
        case webSocketData = "data"
    }
    
    public init(webSocketData: [WebSocketDatum]) {
        self.webSocketData = webSocketData
    }
}

public struct WebSocketDatum : Codable, Hashable, Equatable {
    public let price: Double
    public var symbol: String
    
    public enum CodingKeys: String, CodingKey {
        case price = "p"
        case symbol = "s"
    }
    
    public init(price: Double, symbol: String) {
        self.price = price
        self.symbol = symbol
    }
}
