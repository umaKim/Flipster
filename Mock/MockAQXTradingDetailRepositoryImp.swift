//
//  MockAQXTradingDetailRepositoryImp.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//
import Service
import Models
import Foundation
import AQXTradeDetailFeature

public class MockAQXTradingDetailRepositoryImp: AQXTradingDetailRepository {
    
    private let networkManager: RESTApiProtocol
    
    public init(networkManager: RESTApiProtocol = MockRESTApiManager()) {
        self.networkManager = networkManager
    }
    
    public func fetchChartData(url: URL) async -> Result<Models.ChartData, Service.APIError> {
        return .success(MockData.chartData)
    }
}
