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
    func fetchChartData(url: URL) async -> Result<Models.ChartData, APIError>
}

public final class AQXTradingDetailRepositoryImp: AQXTradingDetailRepository {
   
    private let networkManager: RESTApiProtocol
    
    public init(networkManager: RESTApiProtocol) {
        self.networkManager = networkManager
    }
    
    public func fetchChartData(url: URL) async -> Result<Models.ChartData, Service.APIError> {
        await networkManager.request(url: url)
    }
}
