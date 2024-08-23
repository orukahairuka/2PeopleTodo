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
           listenerRegistration = db.collection("groups").document(groupCode).collection("tasks")
               .addSnapshotListener { querySnapshot, error in
                   guard let documents = querySnapshot?.documents else {
                       print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                       return
                   }

                   self.tasks = documents.compactMap { document -> Task? in
                       try? document.data(as: Task.self)
                   }.filter { !$0.isCompleted }

                   self.completedTasks = documents.compactMap { document -> Task? in
                       try? document.data(as: Task.self)
                   }.filter { $0.isCompleted }
               }
       }

    func addTask(title: String, groupCode: String, createdBy: String) {
        let newTask = Task(id: UUID().uuidString, title: title, isCompleted: false, completedAt: nil, createdBy: createdBy)

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
}
