//
//  AQXTradingDetailRepository.swift
//  AQXTradeDetailFeature
//
//  Created by 김윤석 on 2023/08/31.
//
import Models
import Service
import Foundation

public protocol AQXTradingDetailRepository {
    func fetchChartData(of symbol: String) async -> Result<Models.ChartData, APIError>
}

public final class AQXTradingDetailRepositoryImp: AQXTradingDetailRepository {
   
    private let networkManager: RESTApiProtocol
    
    public init(networkManager: RESTApiProtocol) {
        self.networkManager = networkManager
    }
    
    public func fetchChartData(of symbol: String) async -> Result<Models.ChartData, Service.APIError> {
        guard let url = url(
            for: "https://finnhub.io/api/v1" + "/crypto/candle",
            queryParams: [
                "symbol":"BINANCE:\(symbol.uppercased())USDT",
                "resolution":"D",
                "from":"\(1572651390)",
                "to":"\(Int(Date().timeIntervalSince1970))"
            ],
            with: [
                "token": "c3c6me2ad3iefuuilms0"
            ]
        ) else { return .failure(.invalidUrl) }
        return await networkManager.request(url: url)
    }
}

extension AQXTradingDetailRepositoryImp: UrlConfigurable { }
