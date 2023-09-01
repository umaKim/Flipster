//
//  TabFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//
import Service
import TradeFeature
import AssetFeature
import SwiftUI

private enum Tab: String, Equatable {
    case trade
    case asset
    
    @ViewBuilder
    var label: some View {
        switch self {
        case .trade:
            Label("Trade", systemImage: "chart.bar.fill")
        case .asset:
            Label("Asset", systemImage: "creditcard")
        }
    }
}

public struct TabFeatureView: View {
    public init() {}
    
    private let tradeFeatureViewModel = TradeFeatureViewModel(
        repository:
            TradeRepositoryImp(
                networkManager: RESTApiManager(),
                websocket: WebSocketApiManager()
            )
    )
    
    public var body: some View {
        TabView {
            NavigationStack {
                TradeFeatureView(tradeFeatureViewModel)
            }
            .tabItem { Tab.trade.label }
            
            NavigationStack {
                AssetsFeatureView()
            }
            .tabItem { Tab.asset.label }
        }
    }
}

