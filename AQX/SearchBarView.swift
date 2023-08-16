//
//  SearchBarView.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            ZStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("Search", text: $text)
                        .foregroundColor(.white)
                        .focused($isFocused)
                }
                .onTapGesture {
                    withAnimation {
                        isEditing = true
                        isFocused = true
                    }
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.gray, lineWidth: 1)
                    .frame(height: 50)
            )
            
            if isEditing {
                Button {
                    withAnimation {
                        isEditing = false
                        text = ""
                        isFocused = false
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(.white)
                }
                .transition(.opacity)
            }
        }
        
    }
}
