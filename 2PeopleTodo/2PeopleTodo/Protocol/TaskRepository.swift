//
//  TaskFirestoreService.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/06.
//

import Foundation
import FirebaseFirestore

/// Firestore を使ったタスクデータのリポジトリ実装
class TaskRepository: TaskRepositoryProtocol {
    private var db = Firestore.firestore()

    func observeTasks(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration {
        let ref = Firestore.firestore()
            .collection("groups")
            .document(groupCode)
            .collection("tasks")

        return ref.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Failed to fetch tasks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let tasks: [TaskEntity] = documents.compactMap { doc in
                try? doc.data(as: TaskDTO.self).toEntity()
            }

            onUpdate(tasks)
        }
    }


    func addTask(_ task: TaskEntity, groupCode: String) {
        let dto = TaskDTO.fromEntity(task)
        let ref = Firestore.firestore()
            .collection("groups")
            .document(groupCode)
            .collection("tasks")
            .document(task.id) // Entityのidを使う

        do {
            try ref.setData(from: dto)
        } catch {
            print("Failed to add task: \(error)")
        }
    }


    func updateTask(_ task: TaskEntity, groupCode: String) {
        let dto = TaskDTO.fromEntity(task)
        let ref = Firestore.firestore()
            .collection("groups")
            .document(groupCode)
            .collection("tasks")
            .document(task.id)

        do {
            try ref.setData(from: dto)
        } catch {
            print("Failed to update task: \(error)")
        }
    }

    func deleteTask(_ task: TaskEntity, groupCode: String) {
        let ref = Firestore.firestore()
            .collection("groups")
            .document(groupCode)
            .collection("tasks")
            .document(task.id)

        ref.delete { error in
            if let error = error {
                print("Failed to delete task: \(error)")
            }
        }
    }
}
