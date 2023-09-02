//
//  TradeFeatureViewModel.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//
import Models
import Service
import Combine
import Foundation

public enum TradeFeatureViewModelNextState: Hashable {
    case detailView
}

public final class TradeFeatureViewModel: ObservableObject {
    @Published var nextState: TradeFeatureViewModelNextState?
    @Published var viewStatus: TradeViewStatus = .normal
    @Published var searchText: String = ""
    @Published private(set) var topMovers: [CoinCapAsset] = []
    @Published private(set) var mostTraded: [CoinCapAsset] = []
    var filteredCryptos: [CoinCapAsset] {
        get {
            if viewStatus == .searching {
                let lowercasedQuery = searchText.uppercased()
                return allCryptos.filter({
                    $0.name.uppercased().contains(lowercasedQuery) ||
                    $0.symbol.uppercased().contains(lowercasedQuery)
                })
            } else {
                return allCryptos
            }
        }
    }
    
    private var allCryptos: [CoinCapAsset] = []
    public var selectedCrypto: CoinCapAsset?
    
    private let repository: TradeRepository
    
    private var cancellables: Set<AnyCancellable>
    
    public init(
        repository: TradeRepository
    ) {
        self.repository = repository
        self.cancellables = .init()
        fetchCoins()
    }
}

// Life Cycle
extension TradeFeatureViewModel {
    func onAppear() {
        selectedCrypto = nil
        nextState = nil
        repository.connect()
    }
    
    func onDisappear() {
        repository.disconnect()
    }
}

// Private methods
extension TradeFeatureViewModel {
    private func fetchCoins() {
        guard let url = coinlistUrl else { return }
        Task { @MainActor in
            let result = await repository.fetchCoins(url: url)
            switch result {
            case .success(let coins):
                self.topMovers = coins.sorted(by: {$0.priceChangePercentage24H > $1.priceChangePercentage24H})
                self.mostTraded = coins.sorted(by: {$0.marketCapChangePercentage24H ?? 0 > $1.marketCapChangePercentage24H ?? 0})
                self.allCryptos = coins
                self.setupWs()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func mapping(for cryptos: [CoinCapAsset], with data: WebSocketDatum) -> [CoinCapAsset] {
        var cryptos = cryptos
        if cryptos.contains(where:{"BINANCE:\($0.symbol.uppercased())USDT" == data.symbol}) {
            for (index, model) in cryptos.enumerated() {
                if "BINANCE:\(model.symbol.uppercased())USDT" == data.symbol {
                    var temp = model
                    temp.currentPrice = data.price
                    cryptos[index] = temp
                    return cryptos
                }
            }
        }
        return []
    }
    
    private func setupWs() {
        repository.connect()
        repository.set(symbols: allCryptos.map({$0.symbol.uppercased()}))
        repository.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] receivedDatum in
                guard let self = self else { return }
                receivedDatum
                    .forEach { data in
                        self.topMovers = self.mapping(for: self.topMovers, with: data)
                        self.mostTraded = self.mapping(for: self.mostTraded, with: data)
                        self.allCryptos = self.mapping(for: self.allCryptos, with: data)
                    }
            })
            .store(in: &cancellables)
    }
}

// UrlConfigurable
extension TradeFeatureViewModel: UrlConfigurable {
    private var coinlistUrl: URL? {
        url(
            for: "https://api.coingecko.com/api/v3/coins/markets",
            queryParams: [
                "vs_currency":"inr",
                "order":"market_cap_desc",
                "per_page":"100",
                "page": "1",
                "sparkline":"true",
                "price_change_percentage":"24h"
            ]
        )
    }
}
