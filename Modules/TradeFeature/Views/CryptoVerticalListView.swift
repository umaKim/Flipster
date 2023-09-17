//
//  CryptoVerticalListView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/24.
//

import SwiftUIImageCachKit
import Models
import SwiftUI

struct CryptoVerticalListView: View {
    @ObservedObject private var viewModel: CryptoListViewModel
    
    public init(
        _ viewModel: CryptoListViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        LazyVStack {
            ForEach(viewModel.cryptos, id: \.id) { element in
                NavigationLink(value: element) {
                    cell(with: element)
                }
            }
        }
    }
    
    private func cell(with element: CoinCapAsset) -> some View {
        HStack {
            CacheImage(
                urlString: element.image,
                content: { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(15)
                        
                    default:
                        Image(systemName: "exclamationmark.circle")
                    }
                }
            )
            
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
        .padding(.vertical, 2)
    }
}
