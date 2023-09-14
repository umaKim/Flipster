//
//  TradeRepositoryDataConvertible.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/09/14.
//

import Models
import Service
import Foundation

public protocol TradeRepositoryDataConvertible { }

extension TradeRepositoryDataConvertible {
    public func convertMessage(with symbols: [String], to completion: @escaping (String) -> Void) {
        Task {
            symbols.forEach({ symbol in
                let symbolForFinHub = "BINANCE:\(symbol)USDT"
                let message = "{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}"
                completion(message)
            })
        }
    }
    
    public func convertTickData(with text: String, to completion: @escaping ([WebSocketDatum]) -> Void) {
        Task {
            if let data: Data = text.data(using: .utf8) {
                if let tickData = try? WebSocketResponse.decode(from: data)?.webSocketData {
                    completion(tickData)
                }
            }
        }
    }
}
