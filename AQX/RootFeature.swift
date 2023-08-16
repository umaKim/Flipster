//
//  RootFeature.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/02.
//

import ComposableArchitecture
import SwiftUI

struct RootReducer: Reducer {
    struct State: Equatable {
        var tabs: IdentifiedArrayOf<TabFeature.State>
        
        init() {
            self.tabs = .init(uniqueElements: [.tradeFeature(.init()), .assetsFeature(.init())])
        }
    }
    
    enum Action: Equatable {
        case tab(id: TabFeature.State.ID, action: TabFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        .forEach(\.tabs, action: /Action.tab) {
            TabFeature()
        }
    }
}

struct RootView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            TabView {
                ForEachStore(store.scope(state: \.tabs, action: RootReducer.Action.tab)) { store in
                    TabFeatureView(store: store)
                }
            }
        }
    }
    
}
