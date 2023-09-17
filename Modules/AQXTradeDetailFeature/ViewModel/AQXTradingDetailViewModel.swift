//
//  AQXTradingDetailViewModel.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/19.
//
import Models
import Service
import Combine
import Foundation

public enum ChartStatus {
    public typealias Message = String
    case data(ChartData?)
    case loading(Message)
    case error(Message)
}

public final class AQXTradingDetailViewModel: ObservableObject {
    public var crypto: CoinCapAsset?
    @Published public var chartStatus: ChartStatus? = nil
    @Published public var priceInput: String = ""
    @Published public var chartViewStatus: AQXTradingDetailChartStatus = .show
    @Published public var tradingType: AQXTradingDetailViewTradingType = .long
    @Published public var selectedLeverageType: LeverageType = .none
    public var reviewYourOrderButtonDisabled: Bool { priceInput.isEmpty }
    private(set) var leverageTypes: [LeverageType] = [.twentyFive, .fifty, .seventyFive, .hundered]
    private let repository: AQXTradingDetailRepository
    private var cancellables: Set<AnyCancellable>
    
    public init(
        crypto: CoinCapAsset?,
        repository: AQXTradingDetailRepository
    ) {
        self.crypto = crypto
        self.repository = repository
        self.cancellables = .init()
    }
    
    private func fetchChartData() {
        chartStatus = .loading("Loading...")
        Task {
            let result = await repository.fetchChartData()
            DispatchQueue.main.async {
                switch result {
                case .success(let chartData):
                    self.chartStatus = .data(chartData)
                case .failure(let error):
                    self.chartStatus = .error(error.localizedDescription)
                }
            }
        }
    }
    
    public func onAppear() {
        fetchChartData()
    }
    
    public func onDisappear() {
        chartStatus = nil
    }
}
