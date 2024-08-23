//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            if appState.isAuthenticated, let groupId = appState.groupId {
                SharedToDoListView(groupId: groupId)
                    .environmentObject(appState)
            } else {
                AuthenticationView()
                    .environmentObject(appState)
            }
        }
    }
}
