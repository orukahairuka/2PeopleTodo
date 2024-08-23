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

    var body: some View {
        List {
            Section(header: Text("フィルター")) {
                Picker("表示するユーザー", selection: $viewModel.selectedUser) {
                    Text("全員").tag(nil as String?)
                    ForEach(Array(Set(viewModel.completedTasks.map { $0.createdBy })), id: \.self) { user in
                        Text(user).tag(user as String?)
                    }
                }
            }

            ForEach(viewModel.filteredCompletedTasks) { task in
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
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let task = viewModel.filteredCompletedTasks[index]
                    if let groupCode = appState.groupCode {
                        viewModel.deleteTask(task, groupCode: groupCode)
                    }
                }
            }
        }
        .navigationTitle("完了したタスク")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
