//
//  SectionHeaderView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/24.
//

import SwiftUI

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
