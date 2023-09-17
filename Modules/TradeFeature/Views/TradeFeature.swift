//
//  TradeFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//

import Models
import AQXTradeDetailFeature
import Service
import SwiftUI
import Utils

public struct TradeFeatureView: View {
    @StateObject private var viewModel: TradeFeatureViewModel
    
    public init(_ viewModel: TradeFeatureViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
   
    public var body: some View {
        contentView
            .padding([.horizontal, .bottom])
            .background(Color(uiColor: .flipsterBlack))
            .onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
            .navigationDestination(for: CoinCapAsset.self) {
                AQXTradingDetailView(
                    .init(
                        crypto: $0,
                        repository: AQXTradingDetailRepositoryImp(
                            networkManager: RESTApiManager()
                        )
                    )
                )
            }
    }
    
    private var contentView: some View {
        VStack {
            SearchBar(text: $viewModel.searchText, status: $viewModel.viewStatus)
            ZStack {
                switch viewModel.viewStatus {
                case .searching:
                    ScrollView {
                        CryptoListView(
                            .init(cryptos: viewModel.filteredCryptos),
                            axis: .vertical,
                            headerView: {
                                usdtPerpetualHeaderTitleView
                            }
                        )
                    }
                case .normal:
                    ScrollView(.vertical, showsIndicators: false) {
                        usdtPerpetualHeaderTitleView
                        
                        CryptoListView(
                            .init(cryptos: viewModel.topMovers),
                            axis: .horizontal,
                            headerView: {
                                SectionHeaderView(sectionHeader: TopMoversHeaderInfo())
                            }
                        ).padding(.bottom)
                        
                        CryptoListView(
                            .init(cryptos: viewModel.mostTraded),
                            axis: .horizontal,
                            headerView: {
                                SectionHeaderView(sectionHeader: MostTradedHeaderInfo())
                            }
                        ).padding(.bottom)
                        
                        CryptoListView(
                            .init(cryptos: viewModel.filteredCryptos),
                            axis: .vertical,
                            headerView: {
                                SectionHeaderView(sectionHeader: AllSelectionHeaderInfo())
                            }
                        )
                    }
                    .listStyle(.insetGrouped)
                case .error(let message):
                    Text(message)
                        .bold()
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var usdtPerpetualHeaderTitleView: some View {
        VStack(spacing: 6) {
            HStack {
                Text("USDT Perpetual")
                    .frame(alignment: .leading)
                    .foregroundColor(.white)
                    .bold()
                    .font(.title3)
                
                Spacer()
            }
            
            Rectangle()
                .foregroundColor(Color(uiColor: .systemGray.withAlphaComponent(0.5)))
                .frame(height: 1)
        }
    }
}
