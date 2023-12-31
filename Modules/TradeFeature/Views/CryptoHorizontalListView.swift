//
//  CryptoHorizontalListView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/20.
//
import SwiftUIImageCachKit
import Models
import SwiftUI

public struct CryptoHorizontalListView: View {
    @ObservedObject private var viewModel: CryptoListViewModel
    
    public init(
        _ viewModel: CryptoListViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.cryptos, id: \.id) { element in
                    NavigationLink(value: element) {
                        cell(with: element)
                    }
                }
            }
        }
    }
    
    private func cell(with element: CoinCapAsset) -> some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center) {
                CacheImage(
                    urlString: element.image,
                    content: { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                            
                        default:
                            Image(systemName: "exclamationmark.circle")
                        }
                    }
                )
                
                VStack(alignment: .leading) {
                    Text(element.symbol.uppercased())
                        .bold()
                        .foregroundColor(.white)
                    Text("\(element.currentPrice.decimalDigits(2))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: (element.priceChangePercentage24H > 0) ? "arrow.up.right" :  "arrow.down.right")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
                
                Text("\(element.priceChangePercentage24H.decimalDigits(2)) %")
                    .font(.title3)
                    .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
            }
        }
        .frame(width: 150, height: 100)
        .background(Color(uiColor: .flipsterGray))
        .cornerRadius(8)
    }
}
