//
//  FilterButton.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/25.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

