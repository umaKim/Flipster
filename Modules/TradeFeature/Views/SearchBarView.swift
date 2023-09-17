//
//  SearchBarView.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var status: TradeViewStatus
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            ZStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                    Spacer()
                    TextField(
                        "",
                        text: $text,
                        onEditingChanged: { isEditing in
                            withAnimation {
                                if isEditing {
                                    self.status = .searching
                                    self.isFocused = isEditing
                                }
                            }
                        }
                    )
                    .focused($isFocused)
                    .placeholder(when: text.isEmpty) {
                        Text("Search products")
                            .foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.gray, lineWidth: 1)
                    .frame(height: 50)
            )
            
            switch status {
            case .searching:
                Button {
                    withAnimation {
                        self.text = ""
                        self.status = .normal
                        self.isFocused = false
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(.white)
                }
                .transition(.opacity)
                
            case .normal:
                EmptyView()
                
            default:
                EmptyView()
            }
        }
    }
}
