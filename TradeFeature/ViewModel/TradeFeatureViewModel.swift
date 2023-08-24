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
    @Published var searchText: String = ""
    
    @Published private(set) var topMovers: [CoinCapAsset] = []
    @Published private(set) var mostTraded: [CoinCapAsset] = []
    @Published private(set) var allCryptos: [CoinCapAsset] = []
    
    @Published public var nextState: TradeFeatureViewModelNextState?
    @Published var isSearching: Bool = false
    
    private var cancellables: Set<AnyCancellable>
    
    public var selectedCrypto: CoinCapAsset?
    
    public var filteredCryptos: [CoinCapAsset] {
        get {
            let lowercasedQuery = searchText.uppercased()
            return allCryptos.filter({
                $0.name.uppercased().contains(lowercasedQuery) ||
                $0.symbol.uppercased().contains(lowercasedQuery)
            })
        }
    }
    
    private let socketService: any CoinDetailRepository
    private let restApiService: NetworkManager
    
    public init(socketService: any CoinDetailRepository, restApiService: NetworkManager) {
        self.socketService = socketService
        self.restApiService = restApiService
        self.cancellables = .init()
        fetchCoins()
    }
}

//Life Cycle
extension TradeFeatureViewModel {
    func onAppear() {
        selectedCrypto = nil
        nextState = nil
        socketService.connect(to: FinnHubSocket())
    }
    
    func onDisappear() {
        socketService.disconnect()
        
    }
}

//Private methods
extension TradeFeatureViewModel {
    private func fetchCoins() {
        guard let url = coinlistUrl else { return }
        Task { @MainActor in
            let result = await restApiService.request(url: url, expecting: [CoinCapAsset].self)
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
    
    private func mapping(for cryptos: [CoinCapAsset], with data: Datum) -> [CoinCapAsset] {
        var cryptos = cryptos
        if cryptos.contains(where:{"BINANCE:\($0.symbol.uppercased())USDT" == data.s}) {
            for (index, model) in cryptos.enumerated() {
                if "BINANCE:\(model.symbol.uppercased())USDT" == data.s {
                    var temp = model
                    temp.currentPrice = data.p
                    cryptos[index] = temp
                    return cryptos
                }
            }
        }
        return []
    }
    
    private func setupWs() {
        socketService.connect(to: FinnHubSocket())
        socketService.set(symbols: allCryptos.map({$0.symbol.uppercased()}))
        socketService.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (receivedDatum: Datum) in
                receivedDatum
                    .forEach {[weak self] data in
                        guard let self = self else { return }
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
            ])
    }
}
