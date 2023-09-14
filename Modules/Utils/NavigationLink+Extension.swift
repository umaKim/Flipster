//
//  NavigationLink+Extension.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/19.
//
import SwiftUI

extension NavigationLink where Label == EmptyView {
    public init<T: Hashable>(destination: Destination, when selection: Binding<T?>, equals tag: T) {
        self.init(
            tag: tag,
            selection: selection,
            destination:{ destination },
            label: { EmptyView() }
        )
    }
}
