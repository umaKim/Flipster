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

public final class TradeFeatureViewModel: ObservableObject {
    @Published var viewStatus: TradeViewStatus = .normal
    @Published var searchText: String = ""
    var topMovers: [CoinCapAsset] {
        return allCryptos
            .sorted {
            $0.priceChangePercentage24H > $1.priceChangePercentage24H
        }
    }
    var mostTraded: [CoinCapAsset] {
        return allCryptos
            .sorted(by: {
                $0.marketCapChangePercentage24H ?? 0 > $1.marketCapChangePercentage24H ?? 0
            })
    }
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
    private let repository: TradeRepository
    private var cancellables: Set<AnyCancellable>
    
    public init(
        repository: TradeRepository
    ) {
        self.repository = repository
        self.cancellables = .init()
    }
    
    private let lock = NSLock()
}

// Life Cycle
extension TradeFeatureViewModel {
    func onAppear() {
        if allCryptos.isEmpty {
            Task {
                await fetchCoins()
            }
        }
    }
    
    func onDisappear() {
        
    }
}

// Private methods
extension TradeFeatureViewModel {
    @MainActor
    private func fetchCoins() {
        Task {
            let result = await repository.fetchCoins()
            switch result {
            case .success(let coins):
                self.allCryptos = coins
                self.setupWebSocket(with: coins)
                
            case .failure(let error):
                self.viewStatus = .error(error.localizedDescription)
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
    
    private func setupWebSocket(with coins: [CoinCapAsset]) {
        repository.connect()
        repository.set(symbols: coins.map({$0.symbol.uppercased()}))
        repository.dataPublisher
            .receive(on: DispatchQueue.global())
            .sink(receiveValue: {[weak self] receivedDatum in
                guard let self = self else { return }
                receivedDatum
                    .forEach { data in
                        self.lock.lock()
                        self.mapping(for: self.allCryptos, with: data) {
                            defer { self.lock.unlock() }
                            self.allCryptos = $0
                            self.objectWillChange.send()
                        }
                    }
            })
            .store(in: &cancellables)
    }
}
