//
//  ColorExtension.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/25.
//

import SwiftUI

extension Color {
    static let customImageColor = Color("ImageColor")
    static let customAccentColor = Color("AccentRed")
    static let customTextFormColor = Color("TextFormColor")
    static let customTextColor = Color("TextColor")
}


struct CustomStyledForm<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.customImageColor)
            
            content
        }
    }
}
