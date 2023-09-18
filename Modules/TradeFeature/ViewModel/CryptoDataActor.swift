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

    func modifyCrypto(with data: WebSocketDatum) {
        if cryptos.lazy.contains(where:{"BINANCE:\($0.symbol.uppercased())USDT" == data.symbol}) {
            for (index, model) in cryptos.enumerated() {
                if "BINANCE:\(model.symbol.uppercased())USDT" == data.symbol {
                    var temp = model
                    temp.currentPrice = data.price
                    cryptos[index] = temp
                }
            }
        }
    }

    func getUpdatedCryptos() -> [CoinCapAsset] {
        return cryptos
    }
}
