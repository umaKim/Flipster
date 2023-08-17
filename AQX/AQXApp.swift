//
//  AQXApp.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/01.
//
import ComposableArchitecture
import SwiftUI
import UIKit

@main
struct AQXApp: App {
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store:
                    .init(
                        initialState: RootReducer.State(),
                        reducer: {
                            RootReducer()
                                ._printChanges()
                        }
                    )
            )
        }
    }
}
