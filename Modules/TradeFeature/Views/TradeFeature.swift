//
//  TradeFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//
import Models
import AQXTradeDetailFeature
import Service
import Kingfisher
import SwiftUI
import Utils

// user Interaction ->
// View -> [ action -> reducer -> state ] -> View

//Store: action -> reducer -> Environment -> Effect -> action
//                         -> State


enum TradeViewStatus {
    case searching
    case normal
}

public struct TradeFeatureView: View {
    @ObservedObject private var viewModel: TradeFeatureViewModel
    
    public init(_ viewModel: TradeFeatureViewModel) {
        self.viewModel = viewModel
    }
   
    public var body: some View {
        
            VStack {
                SearchBar(text: $viewModel.searchText, status: $viewModel.viewStatus)
                ZStack {
                    switch viewModel.viewStatus {
                    case .searching:
                        ScrollView {
                            CryptoListView(
                                viewModel: .init(cryptos: viewModel.filteredCryptos),
                                axis: .vertical,
                                headerView: {
                                    usdtPerpetualHeaderTitleView
                                },
                                onTap: {
                                    viewModel.nextState = .detailView
                                    viewModel.selectedCrypto = $0
                                }
                            )
                        }
                    case .normal:
                        ScrollView(.vertical, showsIndicators: false) {
                            usdtPerpetualHeaderTitleView
                            
                            CryptoListView(
                                viewModel: .init(cryptos: viewModel.topMovers),
                                axis: .horizontal,
                                headerView: {
                                    SectionHeaderView(sectionHeader: TopMoversHeaderInfo())
                                },
                                onTap: {
                                    viewModel.nextState = .detailView
                                    viewModel.selectedCrypto = $0
                                }
                            ).padding(.bottom)
                            
                            CryptoListView(
                                viewModel: .init(cryptos: viewModel.mostTraded),
                                axis: .horizontal,
                                headerView: {
                                    SectionHeaderView(sectionHeader: MostTradedHeaderInfo())
                                },
                                onTap: {
                                    viewModel.nextState = .detailView
                                    viewModel.selectedCrypto = $0
                                }
                            ).padding(.bottom)
                            
                            CryptoListView(
                                viewModel: .init(cryptos: viewModel.filteredCryptos),
                                axis: .vertical,
                                headerView: {
                                    SectionHeaderView(sectionHeader: AllSelectionHeaderInfo())
                                },
                                onTap: {
                                    viewModel.nextState = .detailView
                                    viewModel.selectedCrypto = $0
                                }
                            )
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .background(Color(uiColor: .flipsterBlack))
            .onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
       
        NavigationLink(
            destination: AQXTradingDetailView(
                .init(
                    crypto: viewModel.selectedCrypto,
                    repository: AQXTradingDetailRepositoryImp(
                        networkManager: RESTApiManager()
                    )
                )
            ),
            when: $viewModel.nextState,
            equals: .detailView
        )
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

