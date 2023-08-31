//
//  CryptoListView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/25.
//
import Models
import SwiftUI

final public class CryptoListViewModel: ObservableObject {
    @Published var cryptos: [CoinCapAsset] = []
    
    public init(
        cryptos: [CoinCapAsset]
    ) {
        self.cryptos = cryptos
    }
}

struct CryptoListView<HeaderContent: View>: View {
    enum Axis {
        case horizontal
        case vertical
    }
    
    @ObservedObject var viewModel: CryptoListViewModel
    let axis: Axis
    let headerView: () -> HeaderContent
    let onTap: (CoinCapAsset) -> Void
    
    init(
        viewModel: CryptoListViewModel,
        axis: Axis,
        @ViewBuilder headerView: @escaping () -> HeaderContent,
        onTap: @escaping (CoinCapAsset) -> Void
    ) {
        self.viewModel = viewModel
        self.axis = axis
        self.headerView = headerView
        self.onTap = onTap
    }
    
    @ViewBuilder
    var body: some View {
        Section {
            switch axis {
            case .horizontal:
                CryptoHorizontalListView(viewModel: viewModel) { element in
                    onTap(element)
                }
            case .vertical:
                CryptoVerticalListView(viewModel: viewModel) { element in
                    onTap(element)
                }
            }
        } header: {
            headerView()
        }
    }
}
