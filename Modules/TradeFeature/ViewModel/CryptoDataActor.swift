//
//  CryptoDataActor.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/09/18.
//

import Models
import Foundation

actor CryptoDataActor {
    private var cryptos: [CoinCapAsset] = []

    func updateCryptos(_ newCryptos: [CoinCapAsset]) {
        cryptos = newCryptos
    }

    func modifyCrypto(with newData: WebSocketDatum) {
        if cryptos.lazy.contains(where:{"BINANCE:\($0.symbol.uppercased())USDT" == newData.symbol}) {
            for (index, oldData) in cryptos.enumerated() {
                if oldData.currentPrice == newData.price { return }
                if "BINANCE:\(oldData.symbol.uppercased())USDT" == newData.symbol {
                    var temp = oldData
                    temp.priceDifference = oldData.currentPrice < newData.price ? .increase : .decrease
                    temp.currentPrice = newData.price
                    cryptos[index] = temp
                }
            }
        }
    }

    func getUpdatedCryptos() -> [CoinCapAsset] {
        return cryptos
    }
}
