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
}


struct CustomForm<Content: View>: UIViewRepresentable {
    let content: Content
    let backgroundColor: UIColor

    init(@ViewBuilder content: () -> Content, backgroundColor: UIColor) {
        self.content = content()
        self.backgroundColor = backgroundColor
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = backgroundColor
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        uiView.tableHeaderView = hostingController.view
        uiView.tableHeaderView?.frame.size.height = uiView.contentSize.height
    }
}
