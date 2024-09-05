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
                        newTaskSection
                        taskListSection
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
        .navigationTitle("ToDoリスト")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            if let groupCode = appState.groupCode {
                viewModel.fetchTasks(groupCode: groupCode)
            }
        }
    }
    
    
    
    private var filterSection: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("フィルター").font(.headline)
                    .foregroundStyle(Color.customTextColor)
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
    
    private var newTaskSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("新しいタスク").font(.headline)
                .foregroundStyle(Color.customTextColor)
            HStack {
                TextField("新しいタスクを入力", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFocused)
                    .background(Color.customTextFormColor)
                    .foregroundColor(Color.customTextColor)
                Button("追加") {
                    addTask()
                }
                .disabled(newTaskTitle.isEmpty)
                .foregroundColor(.customTextColor)
            }
        }
    }
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("タスク一覧").font(.headline)
                .foregroundStyle(Color.customTextColor)
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task) {
                    if let groupCode = appState.groupCode {
                        viewModel.completeTask(task, groupCode: groupCode)
                    }
                }
                .foregroundColor(Color.customTextColor)
                .background(Color.customTextFormColor)
            }
        }
    }
    
    private func addTask() {
        if let groupCode = appState.groupCode, let username = appState.username, let userId = appState.userId {
            viewModel.addTask(title: newTaskTitle, groupCode: groupCode, createdBy: username, userId: userId)
            newTaskTitle = ""
            isFocused = false
            updateAllUsers()
        }
    }
    
    private func updateAllUsers() {
        let users = Set(viewModel.tasks.map { $0.createdBy } + viewModel.completedTasks.map { $0.createdBy })
        allUsers = Array(users).sorted()
    }
}
struct TaskRow: View {
    let task: Task
    let completeAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                Text("作成者: \(task.createdBy)")
                    .font(.caption)
                    .foregroundColor(Color.customTextColor)
            }
            Spacer()
            Button(action: completeAction) {
                Image(systemName: "checkmark.circle")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
