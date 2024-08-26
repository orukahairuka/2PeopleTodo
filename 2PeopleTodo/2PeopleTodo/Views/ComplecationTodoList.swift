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
            Color.customImageColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    filterSection
                    completedTasksSection
                }
                .padding()
            }
        }
        .navigationTitle("完了したタスク")
        .background(Color.customImageColor)
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
                    ForEach(allUsers, id: \.self) { user in
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
        let completedUsers = Set(viewModel.completedTasks.map { $0.createdBy })
        let activeUsers = Set(viewModel.tasks.map { $0.createdBy })
        allUsers = Array(completedUsers.union(activeUsers)).sorted()
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()
extension TodoListViewModel {
    var sortedFilteredCompletedTasks: [Task] {
        return filteredCompletedTasks.sorted { (task1, task2) -> Bool in
            guard let date1 = task1.completedAt, let date2 = task2.completedAt else {
                return false // タスクに完了日がない場合は順序を変えない
            }
            return date1 > date2 // 降順（新しい日付が先）
        }
    }
}
