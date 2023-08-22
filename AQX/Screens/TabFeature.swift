//
//  TabFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//
import TradeFeature
import AssetFeature
import ComposableArchitecture
import SwiftUI

enum Tab: String, Equatable {
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

struct TabFeatureView: View {
    var body: some View {
        TabView {
            NavigationStack{
                TradeFeatureView(vm: TradeFeatureViewModel())
            }
            .tabItem { Tab.trade.label }

            NavigationStack {
                AssetsFeatureView()
            }
            .tabItem { Tab.asset.label }
        }
    }
}

