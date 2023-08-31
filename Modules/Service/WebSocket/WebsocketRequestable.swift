//
//  WebsocketRequestable.swift
//  AQXTradeDetailFeature
//
//  Created by 김윤석 on 2023/08/31.
//

import Foundation

public protocol WebsocketRequestable {
    func urlMaker() -> URL
}
