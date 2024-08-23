//
//  TodoList.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ToDo: Identifiable {
    let id: String
    var title: String
    var isCompleted: Bool
    let createdBy: String
}

class SharedToDoListViewModel: ObservableObject {
    @Published var todos: [ToDo] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    func fetchTodos(groupId: String) {
        listenerRegistration = db.collection("todoLists").document(groupId).collection("todos")
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
                                createdBy: data["createdBy"] as? String ?? "")
                }
            }
    }

    func addTodo(title: String, groupId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let newTodo = [
            "title": title,
            "isCompleted": false,
            "createdBy": userId,
            "createdAt": Timestamp()
        ] as [String : Any]

        db.collection("todoLists").document(groupId).collection("todos").addDocument(data: newTodo)
    }

    func toggleTodoCompletion(todo: ToDo, groupId: String) {
        db.collection("todoLists").document(groupId).collection("todos").document(todo.id).updateData([
            "isCompleted": !todo.isCompleted
        ])
    }

    func deleteTodo(todo: ToDo, groupId: String) {
        db.collection("todoLists").document(groupId).collection("todos").document(todo.id).delete()
    }

    deinit {
        listenerRegistration?.remove()
    }
}

struct SharedToDoListView: View {
    @StateObject private var viewModel = SharedToDoListViewModel()
    @State private var newTodoTitle = ""
    let groupId: String

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.todos) { todo in
                    HStack {
                        Button(action: {
                            viewModel.toggleTodoCompletion(todo: todo, groupId: groupId)
                        }) {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        Text(todo.title)
                        Spacer()
                        Text(todo.createdBy)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { indexSet in
                    let todosToDelete = indexSet.map { viewModel.todos[$0] }
                    todosToDelete.forEach { todo in
                        viewModel.deleteTodo(todo: todo, groupId: groupId)
                    }
                }
            }

            HStack {
                TextField("新しいToDoを追加", text: $newTodoTitle)
                Button("追加") {
                    viewModel.addTodo(title: newTodoTitle, groupId: groupId)
                    newTodoTitle = ""
                }
            }
            .padding()
        }
        .navigationTitle("共有ToDoリスト")
        .onAppear {
            viewModel.fetchTodos(groupId: groupId)
        }
    }
}
