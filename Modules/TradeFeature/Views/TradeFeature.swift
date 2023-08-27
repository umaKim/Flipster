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

public struct TradeFeatureView: View {
    @ObservedObject public var vm: TradeFeatureViewModel
    
    public init(vm: TradeFeatureViewModel) {
        self.vm = vm
    }
    
    public var body: some View {
        VStack {
            SearchBar(text: $vm.searchText, isEditing: $vm.isSearching)
            ZStack {
                if vm.isSearching {
                    ScrollView {
                        CryptoListView(
                            vm: .init(cryptos: vm.filteredCryptos),
                            axis: .vertical,
                            headerView: {
                                usdtPerpetualHeaderTitleView
                            },
                            onTap: {
                                vm.nextState = .detailView
                                vm.selectedCrypto = $0
                            }
                        )
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        usdtPerpetualHeaderTitleView
                        
                        CryptoListView(
                            vm: .init(cryptos: vm.topMovers),
                            axis: .horizontal,
                            headerView: {
                                SectionHeaderView(sectionHeader: TopMoversHeaderInfo())
                            },
                            onTap: {
                                vm.nextState = .detailView
                                vm.selectedCrypto = $0
                            }
                        ).padding(.bottom)
                        
                        CryptoListView(
                            vm: .init(cryptos: vm.mostTraded),
                            axis: .horizontal,
                            headerView: {
                                SectionHeaderView(sectionHeader: MostTradedHeaderInfo())
                            },
                            onTap: {
                                vm.nextState = .detailView
                                vm.selectedCrypto = $0
                            }
                        ).padding(.bottom)
                        
                        CryptoListView(
                            vm: .init(cryptos: vm.filteredCryptos),
                            axis: .vertical,
                            headerView: {
                                SectionHeaderView(sectionHeader: AllSelectionHeaderInfo())
                            },
                            onTap: {
                                vm.nextState = .detailView
                                vm.selectedCrypto = $0
                            }
                        )
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .padding([.horizontal, .bottom])
        .background(Color(uiColor: .flipsterBlack))
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        
        NavigationLink(
            destination: AQXTradingDetailView(
                vm: .init(
                    crypto: vm.selectedCrypto,
                    service: NetworkManager()
                )
            ),
            when: $vm.nextState,
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

