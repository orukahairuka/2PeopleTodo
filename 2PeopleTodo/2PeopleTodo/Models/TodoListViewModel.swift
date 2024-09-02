//
//  TodoListViewModel.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import Foundation
import FirebaseFirestore

class TodoListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var completedTasks: [Task] = []
    @Published var selectedUser: String?
    @Published var allUsers: [String] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    var filteredTasks: [Task] {
        guard let selectedUser = selectedUser else { return tasks }
        return tasks.filter { $0.createdBy == selectedUser }
    }

    var filteredCompletedTasks: [Task] {
        guard let selectedUser = selectedUser else { return completedTasks }
        return completedTasks.filter { $0.createdBy == selectedUser }
    }

    func fetchTasks(groupCode: String) {
        listenerRegistration?.remove()
        listenerRegistration = db.collection("groups").document(groupCode).collection("tasks")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let allTasks = documents.compactMap { document -> Task? in
                    try? document.data(as: Task.self)
                }

                self.tasks = allTasks.filter { !$0.isCompleted }
                self.completedTasks = allTasks.filter { $0.isCompleted }
                
                self.updateAllUsers()
                self.objectWillChange.send()
            }
    }

    func addTask(title: String, groupCode: String, createdBy: String, userId: String) {
        let newTask = Task(id: UUID().uuidString, title: title, isCompleted: false, completedAt: nil, createdBy: createdBy, userId: userId)

        do {
            try db.collection("groups").document(groupCode).collection("tasks").document(newTask.id).setData(from: newTask)
        } catch let error {
            print("Error adding task: \(error)")
        }
    }

    func completeTask(_ task: Task, groupCode: String) {
        var updatedTask = task
        updatedTask.isCompleted = true
        updatedTask.completedAt = Date()

        do {
            try db.collection("groups").document(groupCode).collection("tasks").document(task.id).setData(from: updatedTask)
        } catch let error {
            print("Error completing task: \(error)")
        }
    }

    func deleteTask(_ task: Task, groupCode: String) {
        db.collection("groups").document(groupCode).collection("tasks").document(task.id).delete() { error in
            if let error = error {
                print("Error deleting task: \(error)")
            }
        }
    }

    private func updateAllUsers() {
        let users = Set(tasks.map { $0.createdBy } + completedTasks.map { $0.createdBy })
        allUsers = Array(users).sorted()
    }

    var sortedFilteredCompletedTasks: [Task] {
        let filtered = selectedUser == nil ? completedTasks : completedTasks.filter { $0.createdBy == selectedUser }
        return filtered.sorted { (task1, task2) -> Bool in
            guard let date1 = task1.completedAt, let date2 = task2.completedAt else {
                return false
            }
            return date1 > date2
        }
    }
}
