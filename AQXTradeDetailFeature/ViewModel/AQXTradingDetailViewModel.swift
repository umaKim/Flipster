//
//  AQXTradingDetailViewModel.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/19.
//

import Combine
import Foundation

final class AQXTradingDetailViewModel: ObservableObject {
    private(set) var crypto: CoinCapAsset?
    
    @Published private(set) var chartData: ChartData?
    @Published var priceInput: String = "0.00"
    
    private var cancellables: Set<AnyCancellable>
    
    init(crypto: CoinCapAsset?) {
        self.cancellables = .init()
        self.crypto = crypto
        
        guard let crypto else { return }
        let url =  NetworkManager.shared.url(
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
        
        //        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(crypto.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        
        NetworkManager.shared.request(url: url, expecting: ChartData.self)
            .receive(on: DispatchQueue.main)
            .sink { comp in
                print(comp)
            } receiveValue: {[weak self] data in
                guard let self else { return }
                self.chartData = data
            }
            .store(in: &cancellables)
    }
    
    func onDisappear() {
        self.chartData = nil
    }
}
