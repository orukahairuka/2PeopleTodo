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
        NavigationView {
            Group {
                if appState.isAuthenticated, let groupCode = appState.groupCode {
                    SharedToDoListView(groupCode: groupCode)
                        .environmentObject(appState)
                        .navigationBarItems(trailing: logoutButton)
                } else {
                    AuthenticationView()
                        .environmentObject(appState)
                }
            }
        }
    }

    private var logoutButton: some View {
        Button("ログアウト") {
            appState.signOut()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
