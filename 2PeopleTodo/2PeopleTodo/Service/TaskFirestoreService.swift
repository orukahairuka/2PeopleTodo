//
//  TaskFirestoreService.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/06.
//

import Foundation
import FirebaseFirestore

class TaskFirestoreService {
    private var db = Firestore.firestore()

    func listenTasks(groupCode: String, onUpdate: @escaping ([Task]) -> Void) -> ListenerRegistration {
        return db.collection("groups").document(groupCode).collection("tasks")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Firestore error: \(error?.localizedDescription ?? "unknown error")")
                    onUpdate([])
                    return
                }
                let tasks = documents.compactMap { try? $0.data(as: Task.self) }
                onUpdate(tasks)
            }
    }

    func addTask(_ task: Task, groupCode: String) {
        try? db.collection("groups").document(groupCode).collection("tasks").document(task.id).setData(from: task)
    }

    func updateTask(_ task: Task, groupCode: String) {
        try? db.collection("groups").document(groupCode).collection("tasks").document(task.id).setData(from: task)
    }

    func deleteTask(_ task: Task, groupCode: String) {
        db.collection("groups").document(groupCode).collection("tasks").document(task.id).delete()
    }
}
