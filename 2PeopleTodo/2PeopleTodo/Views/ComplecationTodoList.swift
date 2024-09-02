//
//  ComplecationTodoList.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: TodoListViewModel
    @State private var allUsers: [String] = []
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Color.white
                    .frame(height: 10)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 5)
                        .offset(y: 5)
                    )
                
                ScrollView {
                    VStack(spacing: 20) {
                        filterSection
                        completedTasksSection
                    }
                    .padding()
                }
                .background(Color.customImageColor)
                
                Color.white
                    .frame(height: 10)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.gray.opacity(0.2)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 5)
                        .offset(y: -5)
                    )
            }
        }
        .navigationTitle("完了したタスク")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateAllUsers()
        }
    }
    
    private var filterSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("フィルター").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterButton(title: "全員", isSelected: viewModel.selectedUser == nil) {
                            viewModel.selectedUser = nil
                        }
                        ForEach(viewModel.allUsers, id: \.self) { user in
                            FilterButton(title: user, isSelected: viewModel.selectedUser == user) {
                                viewModel.selectedUser = user
                            }
                        }
                    }
                }
            }
        }
    
    private var completedTasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("完了したタスク").font(.headline)
            ForEach(viewModel.sortedFilteredCompletedTasks) { task in
                CompletedTaskRow(task: task)
            }
        }
    }
    
    private func updateAllUsers() {
        let users = Set(viewModel.tasks.map { $0.createdBy } + viewModel.completedTasks.map { $0.createdBy })
        allUsers = Array(users).sorted()
    }
}

struct CompletedTaskRow: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .strikethrough()
            Text("作成者: \(task.createdBy)")
                .font(.caption)
                .foregroundColor(.secondary)
            if let completedAt = task.completedAt {
                Text("完了: \(completedAt, formatter: itemFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}

