//
//  FinnHubSocket.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/23.
//

import Foundation

public struct FinnHubSocket: WebsocketRequestable, UrlConfigurable {
    public init() { }
    
    public func urlMaker() -> URL {
        url(
            for: CryptoConstants.baseUrl,
            with: ["token" : CryptoConstants.apiKey]
        )!
    }

    fileprivate enum CryptoConstants {
        static let apiKey = "c3c6me2ad3iefuuilms0"
        static let baseUrl = "wss://ws.finnhub.io"
    }
}
