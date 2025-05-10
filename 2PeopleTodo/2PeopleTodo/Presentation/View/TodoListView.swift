//
//  TodoListView.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var viewModel: TodoListViewModel

    @State private var newTaskTitle: String = ""
    @FocusState private var isFocused: Bool

    let groupCode: String
    let createdBy: String
    let userId: String

    var body: some View {
        VStack {
            // ユーザー切り替えフィルター
            Picker("ユーザー", selection: $viewModel.selectedUser) {
                Text("すべて").tag(String?.none)
                ForEach(viewModel.allUsers, id: \.self) { user in
                    Text(user).tag(String?.some(user))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // タスク一覧
            List {
                ForEach(viewModel.filteredTasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Button(action: {
                            viewModel.completeTask(task, groupCode: groupCode)
                        }) {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let task = viewModel.filteredTasks[index]
                        viewModel.deleteTask(task, groupCode: groupCode)
                    }
                }
            }

            // 新規タスク入力欄
            HStack {
                TextField("新しいタスクを追加", text: $newTaskTitle)
                    .focused($isFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("追加") {
                    viewModel.addTask(title: newTaskTitle, groupCode: groupCode, createdBy: createdBy, userId: userId)
                    newTaskTitle = ""
                    isFocused = false
                }
                .disabled(newTaskTitle.isEmpty)
            }
            .padding()
        }
        .navigationTitle("タスク")
        .onAppear {
            viewModel.fetchTasks(groupCode: groupCode)
        }
    }
}
