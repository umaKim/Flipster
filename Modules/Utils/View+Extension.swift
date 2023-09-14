//
//  View+Extension.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/19.
//

import SwiftUI

extension View {
    public func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
