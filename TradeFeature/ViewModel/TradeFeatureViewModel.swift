//
//  TradeFeatureViewModel.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//
import Combine
import Foundation

enum TradeFeatureViewModelNextState: Hashable {
    case detailView
}

public final class TradeFeatureViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    @Published var topMovers: [CoinCapAsset] = []
    @Published var mostTraded: [CoinCapAsset] = []
    @Published var allCryptos: [CoinCapAsset] = []
    
    @Published var nextState: TradeFeatureViewModelNextState?
    @Published var isSearching: Bool = false
    
    private var cancellables: Set<AnyCancellable>
    
    var selectedCrypto: CoinCapAsset?
    
    var filteredCryptos: [CoinCapAsset] {
        get {
            let lowercasedQuery = searchText.uppercased()
            return allCryptos.filter({
                $0.name.uppercased().contains(lowercasedQuery) ||
                $0.symbol.uppercased().contains(lowercasedQuery)
            })
        }
    }
    
    init() {
        self.cancellables = .init()
        fetchCoins()
    }
    
    private let socket = CoinDetailRepositoryImp(StarScreamWebSocket())
    
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
        socket.connect()
        socket.set(symbols: allCryptos.map({$0.symbol.uppercased()}))
        socket.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { receivedDatum in
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
    
    func onAppear() {
        selectedCrypto = nil
        nextState = nil
        socket.connect()
    }
    
    func onDisappear() {
        socket.disconnect()
    }
    
    private func fetchCoins() {
        NetworkManager.shared.request(
            url: .init(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h"),
            expecting: [CoinCapAsset].self
        )
        .receive(on: DispatchQueue.main)
        .sink { comp in
            switch comp {
            case .finished:
                print("finished")
            
            case let .failure(error):
                print(error.localizedDescription)
            }
        } receiveValue: {[weak self] coins in
            guard let self = self else { return }
            self.topMovers = coins.sorted(by: {$0.priceChangePercentage24H > $1.priceChangePercentage24H})
            self.mostTraded = coins.sorted(by: {$0.marketCapChangePercentage24H ?? 0 > $1.marketCapChangePercentage24H ?? 0})
            self.allCryptos = coins
            
            self.setupWs()
        }
        .store(in: &cancellables)
        
    }
    
}
