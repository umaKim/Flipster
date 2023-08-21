//
//  CryptoHorizontalListView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/20.
//

import SwiftUI

public struct CryptoHorizontalListView: View {
    @ObservedObject var vm: TradeFeatureViewModel
    var onTap: (CoinCapAsset) -> Void
    
    public init(vm: TradeFeatureViewModel, onTap: @escaping (CoinCapAsset) -> Void) {
        self.vm = vm
        self.onTap = onTap
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(vm.mostTraded, id: \.id) { element in
                    cell(with: element)
                }
            }
        }
    }

    private func cell(with element: CoinCapAsset) -> some View {
        Button {
            onTap(element)
        } label: {
            VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center) {
                    KFImage(.init(string: element.image))
                        .placeholder({ progress in
                            Image(systemName: "person.circle")
                        })
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading) {
                        Text(element.symbol.uppercased())
                                  .bold()
                            .foregroundColor(.white)
                        Text("\(element.currentPrice.toPercentDecimal ?? "0")")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Image(systemName: (element.priceChangePercentage24H > 0) ? "arrow.up.right" :  "arrow.down.right")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
                    
                    Text("\(element.priceChangePercentage24H.toPercentDecimal ?? "0") %")
                        .font(.title3)
                        .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
                }
            }
            .frame(width: 150, height: 100)
            .background(Color(uiColor: .flipsterGray))
        }
        .cornerRadius(8)
    }
}
