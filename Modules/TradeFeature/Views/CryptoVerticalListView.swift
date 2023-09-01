//
//  CryptoVerticalListView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/24.
//
import Kingfisher
import Models
import SwiftUI

struct CryptoVerticalListView: View {
    @ObservedObject private var viewModel: CryptoListViewModel
    private var onTap: (CoinCapAsset) -> Void
    
    public init(
        _ viewModel: CryptoListViewModel,
        onTap: @escaping (CoinCapAsset) -> Void
    ) {
        self.viewModel = viewModel
        self.onTap = onTap
    }
    
    var body: some View {
        LazyVStack {
            ForEach(
                viewModel.cryptos,
                id: \.id
            ) { element in
                Button {
                    onTap(element)
                } label: {
                    cell(with: element)
                        .padding(.vertical, 2)
                }
            }
        }
    }
    
    private func cell(with element: CoinCapAsset) -> some View {
        HStack {
            KFImage(.init(string: element.image))
                .placeholder({ progress in
                    Image(systemName: "person.circle")
                })
                .resizable()
                .frame(width: 30, height: 30)
                .cornerRadius(15)

            VStack(alignment: .leading) {
                Text(element.symbol.uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                Text(element.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(element.currentPrice.decimalDigits(2) ?? "0")")
                    .foregroundColor(.white)
                Text("\(element.priceChangePercentage24H.decimalDigits(2) ?? "0") %")
                    .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
            }
        }
        .padding(.horizontal, 12)
        .background(Color(uiColor: .flipsterGray))
        .cornerRadius(6)
    }
}
