//
//  TodoList.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseFirestore

struct ToDo: Identifiable {
    let id: String
    let title: String
    var isCompleted: Bool
    let createdBy: String
}

class SharedToDoListViewModel: ObservableObject {
    @Published var todos: [ToDo] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    func fetchTodos(groupCode: String) {
        listenerRegistration = db.collection("groups").document(groupCode).collection("todos")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.todos = documents.compactMap { document -> ToDo? in
                    let data = document.data()
                    return ToDo(id: document.documentID,
                                title: data["title"] as? String ?? "",
                                isCompleted: data["isCompleted"] as? Bool ?? false,
                                createdBy: data["createdBy"] as? String ?? "Unknown")
                }
            }
    }

    func addTodo(title: String, groupCode: String, createdBy: String) {
        let newTodo = [
            "title": title,
            "isCompleted": false,
            "createdBy": createdBy,
            "createdAt": Timestamp()
        ] as [String : Any]

        db.collection("groups").document(groupCode).collection("todos").addDocument(data: newTodo)
    }

    func toggleTodoCompletion(todo: ToDo, groupCode: String) {
        db.collection("groups").document(groupCode).collection("todos").document(todo.id).updateData([
            "isCompleted": !todo.isCompleted
        ])
    }

    func deleteTodo(todo: ToDo, groupCode: String) {
        db.collection("groups").document(groupCode).collection("todos").document(todo.id).delete()
    }

    deinit {
        listenerRegistration?.remove()
    }
}

struct SharedToDoListView: View {
    @StateObject private var viewModel = SharedToDoListViewModel()
    @EnvironmentObject var appState: AppState
    @State private var newTodoTitle = ""
    let groupCode: String

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.todos) { todo in
                    HStack {
                        Button(action: {
                            viewModel.toggleTodoCompletion(todo: todo, groupCode: groupCode)
                        }) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        VStack(alignment: .leading) {
                            Text(todo.title)
                            Text("作成者: \(todo.createdBy)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    let todosToDelete = indexSet.map { viewModel.todos[$0] }
                    todosToDelete.forEach { todo in
                        viewModel.deleteTodo(todo: todo, groupCode: groupCode)
                    }
                }
            }

            HStack {
                TextField("新しいToDoを追加", text: $newTodoTitle)
                Button("追加") {
                    if let username = appState.username {
                        viewModel.addTodo(title: newTodoTitle, groupCode: groupCode, createdBy: username)
                        newTodoTitle = ""
                    }
                }
            }
            .padding()
        }
        .navigationTitle("共有ToDoリスト")
        .onAppear {
            viewModel.fetchTodos(groupCode: groupCode)
        }
    }
}

struct TodoListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var newTaskTitle = ""

    var body: some View {
        List {
            Section(header: Text("新しいタスク")) {
                HStack {
                    TextField("新しいタスクを入力", text: $newTaskTitle)
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
                ForEach(viewModel.tasks) { task in
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
