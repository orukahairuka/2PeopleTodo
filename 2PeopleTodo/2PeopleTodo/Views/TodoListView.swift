//
//  TodoList.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseFirestore

struct TodoListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var newTaskTitle = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.gray.opacity(0)
                           .edgesIgnoringSafeArea(.all)
                           .onTapGesture {
                               isFocused = false
                           }
            List {
                Section(header: Text("フィルター")) {
                    Picker("表示するユーザー", selection: $viewModel.selectedUser) {
                        Text("全員").tag(nil as String?)
                        ForEach(Array(Set(viewModel.tasks.map { $0.createdBy })), id: \.self) { user in
                            Text(user).tag(user as String?)
                        }
                    }
                }

                Section(header: Text("新しいタスク")) {
                    HStack {
                        TextField("新しいタスクを入力", text: $newTaskTitle)
                            .onTapGesture {
                                isFocused.toggle()
                            }
                        Button("追加") {
                            if let groupCode = appState.groupCode, let username = appState.username {
                                viewModel.addTask(title: newTaskTitle, groupCode: groupCode, createdBy: username)
                                newTaskTitle = ""
                            }
                        }
                        .disabled(newTaskTitle.isEmpty)
                    }
                }

                Section(header: Text("タスク一覧")) {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                Text("作成者: \(task.createdBy)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                if let groupCode = appState.groupCode {
                                    viewModel.completeTask(task, groupCode: groupCode)
                                }
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }
                }
            }
            .navigationTitle("ToDoリスト")

        }
    }
}
