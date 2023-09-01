//
//  BarButton.swift
//  AQXTradeDetailFeature
//
//  Created by 김윤석 on 2023/09/02.
//

import SwiftUI

struct BarButton: View {
    let text: String
    let imageName: String
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 6) {
                HStack(alignment: .center) {
                    Text(text)
                        .bold()
                    Image(systemName: imageName)
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                Rectangle()
                    .background(.red)
                    .frame(height: 3)
            }
            .frame(width: UIScreen.main.bounds.width/2)
        }
    }
}
