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

enum TradeViewStatus {
    case searching
    case normal
    case error(String)
}

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
            switch viewStatus {
            case .searching:
                let lowercasedQuery = searchText.uppercased()
                return allCryptos.lazy.filter({
                    $0.name.uppercased().contains(lowercasedQuery) ||
                    $0.symbol.uppercased().contains(lowercasedQuery)
                })
            case .normal:
                return allCryptos
                
            case .error:
                return []
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
    }
}

// Life Cycle
extension TradeFeatureViewModel {
    func onAppear() {
        if allCryptos.isEmpty {
            fetchCoins()
        }
    }
    
    func onDisappear() {
        repository.disconnect()
    }
}

// Private methods
extension TradeFeatureViewModel {
    private func fetchCoins() {
        Task {
            let result = await repository.fetchCoins()
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
    
    private func mapping(for cryptos: [CoinCapAsset], with data: WebSocketDatum, completion: @escaping ([CoinCapAsset]) -> Void) {
        var cryptos = cryptos
        if cryptos.lazy.contains(where:{"BINANCE:\($0.symbol.uppercased())USDT" == data.symbol}) {
            for (index, model) in cryptos.enumerated() {
                if "BINANCE:\(model.symbol.uppercased())USDT" == data.symbol {
                    DispatchQueue.main.async {
                        var temp = model
                        temp.currentPrice = data.price
                        cryptos[index] = temp
                        completion(cryptos)
                    }
                }
            }
        }
    }
    
    private func setupWs() {
        repository.connect()
        repository.set(symbols: allCryptos.map({$0.symbol.uppercased()}))
        repository.dataPublisher
            .receive(on: DispatchQueue.global())
            .sink(receiveValue: {[weak self] receivedDatum in
                guard let self = self else { return }
                receivedDatum
                    .forEach { data in
                        self.mapping(for: self.topMovers, with: data) {
                            self.topMovers = $0
                        }
                        self.mapping(for: self.mostTraded, with: data) {
                            self.mostTraded = $0
                        }
                        self.mapping(for: self.allCryptos, with: data) {
                            self.allCryptos = $0
                        }
                    }
            })
            .store(in: &cancellables)
    }
}
