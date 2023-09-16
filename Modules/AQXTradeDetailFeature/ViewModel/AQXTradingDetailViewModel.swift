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
    
    public var reviewYourOrderButtonDisabled: Bool {
        return priceInput.isEmpty
    }
    
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
    
    public func fetchChartData() {
        chartStatus = .loading("Loading...")
        guard let url = coinChartDataUrl else { return }
        Task {
            let result = await repository.fetchChartData(url: url)
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

extension AQXTradingDetailViewModel: UrlConfigurable {
    private var coinChartDataUrl: URL? {
        guard let crypto else { return nil }
        return url(
            for: "https://finnhub.io/api/v1" + "/crypto/candle",
            queryParams: [
                "symbol":"BINANCE:\(crypto.symbol.uppercased())USDT",
                "resolution":"D",
                "from":"\(1572651390)",
                "to":"\(Int(Date().timeIntervalSince1970))"
            ],
            with: [
                "token": "c3c6me2ad3iefuuilms0"
            ]
        )
    }
}
