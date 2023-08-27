//
//  SectionHeaderView.swift
//  TradeFeature
//
//  Created by 김윤석 on 2023/08/24.
//

import SwiftUI

protocol SectionHeaderInfoViewable {
    var title: String { get }
    var subtitle: String { get }
}

struct TopMoversHeaderInfo: SectionHeaderInfoViewable {
    let title: String = "Top movers"
    let subtitle: String = "Discover high-return opportunities with risk. (24h)"
}

struct MostTradedHeaderInfo: SectionHeaderInfoViewable {
    let title: String = "Most traded"
    let subtitle: String = "Discover tokens with the highest trading volume. (24h)"
}

struct AllSelectionHeaderInfo: SectionHeaderInfoViewable {
    var title: String = "All Selections"
    var subtitle: String = "All crypto and their latest prices, by market cap"
}

struct SectionHeaderView: View {
    let sectionHeader: SectionHeaderInfoViewable
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(sectionHeader.title)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .bold()
                Text(sectionHeader.subtitle)
                    .foregroundColor(.white)
                    .font(.footnote)
            }
            Spacer()
        }
    }
}


