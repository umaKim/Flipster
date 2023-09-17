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
}

// Life Cycle
extension TradeFeatureViewModel {
    func onAppear() {
        if allCryptos.isEmpty {
            fetchCoins()
        }
    }
    
    func onDisappear() {
        
    }
}

// Private methods
extension TradeFeatureViewModel {
    private func fetchCoins() {
        Task {
            let result = await repository.fetchCoins()
            switch result {
            case .success(let coins):
                self.allCryptos = coins
                self.setupWs()
            case .failure(let error):
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
                        self.mapping(for: self.allCryptos, with: data) {
                            self.allCryptos = $0
                        }
                    }
            })
            .store(in: &cancellables)
    }
}
