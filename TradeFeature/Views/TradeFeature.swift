//
//  TradeFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//
import Kingfisher
import SwiftUI
import Utils

// user Interaction ->
// View -> [ action -> reducer -> state ] -> View

//Store: action -> reducer -> Environment -> Effect -> action
//                         -> State

public struct TradeFeatureView: View {
    @ObservedObject var vm: TradeFeatureViewModel
    
    public init(vm: TradeFeatureViewModel) {
        self.vm = vm
    }
    
   public var body: some View {
            ZStack {
                VStack {
                    SearchBar(text: $vm.searchText, isEditing: $vm.isSearching)
                    ZStack {
                        if vm.isSearching {
                            ScrollView {
                                Section {
                                    CryptoVerticalListView(
                                        vm: vm,
                                        isEditingMode: $vm.isSearching,
                                        onTap: { element in
                                            vm.nextState = .detailView
                                            vm.selectedCrypto = element
                                        }
                                    )
                                } header: {
                                    usdtPerpetualHeaderTitleView
                                }
                            }
                           
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
                                usdtPerpetualHeaderTitleView

                                topMoversList
                                    .padding(.bottom)
                                
                                mostTradedList
                                    .padding(.bottom)
                                
                                allSelectionsList
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .background(Color(uiColor: .flipsterBlack))
            .onAppear {
                vm.onAppear()
            }
            .onDisappear {
                vm.onDisappear()
            }
        
        NavigationLink(
            destination: AQXTradingDetailView(vm: .init(crypto: vm.selectedCrypto)),
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
    
    private var topMoversList: some View {
        // top movers
        Section {
            CryptoHorizontalListView(vm: vm) { element in
                vm.nextState = .detailView
                vm.selectedCrypto = element
            }
        } header: {
            SectionHeaderView(
                title: "Top movers",
                subtitle: "Discover high-return opportunities with risk. (24h)"
            )
        }
    }
    
    private var mostTradedList: some View {
        // most traded
        Section {
            CryptoHorizontalListView(vm: vm) { element in
                vm.nextState = .detailView
                vm.selectedCrypto = element
            }
        } header: {
            SectionHeaderView(
                title: "Most traded",
                subtitle: "Discover tokens with the highest trading volume. (24h)"
            )
        }
    }
    
    private var allSelectionsList: some View {
        //All selections
        Section {
            CryptoVerticalListView(vm: vm, isEditingMode: .constant(false)) { element in
                vm.nextState = .detailView
                vm.selectedCrypto = element
            }
        } header: {
            SectionHeaderView(
                title: "All Selections",
                subtitle: "All crypto and their latest prices, by market cap"
            )
        }
    }
    
}

struct SectionHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .bold()
                Text(subtitle)
                    .foregroundColor(.white)
                    .font(.footnote)
            }
            Spacer()
        }
    }
}

public struct CryptoHorizontalListView: View {
    @ObservedObject var vm: TradeFeatureViewModel
    var onTap: (CoinCapAsset) -> Void
    
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
                        Text("\(element.currentPrice.decimalDigits(2) ?? "0")")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Image(systemName: (element.priceChangePercentage24H > 0) ? "arrow.up.right" :  "arrow.down.right")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color(uiColor: (element.priceChangePercentage24H > 0) ? .green : .red))
                    
                    Text("\(element.priceChangePercentage24H.decimalDigits(2) ?? "0") %")
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

struct CryptoVerticalListView: View {
    @ObservedObject var vm: TradeFeatureViewModel
    @Binding var isEditingMode: Bool
    var onTap: (CoinCapAsset) -> Void
    
    var body: some View {
        LazyVStack {
            ForEach(
                isEditingMode ? vm.filteredCryptos : vm.allCryptos,
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
