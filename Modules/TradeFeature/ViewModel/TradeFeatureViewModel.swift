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
import SwiftUI

enum TradeViewStatus {
    case searching
    case normal
    case error(String)
}

public final class TradeFeatureViewModel: ObservableObject {
    private let cryptoDataActor = CryptoDataActor()
    @Published var viewStatus: TradeViewStatus = .normal
    @Published var searchText: String = ""
    var topMovers: [CoinCapAsset] {
        return allCryptos.lazy
            .sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }
    }
    var mostTraded: [CoinCapAsset] {
        return allCryptos.lazy
            .sorted(by: { $0.marketCapChange24H ?? 0 > $1.marketCapChange24H ?? 0 })
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
    @Published private var allCryptos: [CoinCapAsset] = []
    
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
                await self.cryptoDataActor.updateCryptos(coins)
                self.setupWebSocket(with: coins)
                
            case .failure(let error):
                self.viewStatus = .error(error.localizedDescription)
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
                self.mapCoinData(receivedDatum: receivedDatum)
            })
            .store(in: &cancellables)
    }
    
    private func mapCoinData(receivedDatum: [WebSocketDatum]) {
        receivedDatum.forEach {[weak self] data in
            guard let self = self else { return }
            Task { @MainActor in
                await self.cryptoDataActor.modifyCrypto(with: data)
                self.allCryptos = await self.cryptoDataActor.getUpdatedCryptos()
            }
        }
    }
}
