//
//  TaskDTO.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// TaskDTO.swift

import Foundation
import FirebaseFirestore

/// Firestoreとやり取りするための構造体
struct TaskDTO: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var isCompleted: Bool
    var completedAt: Date?
    var createdBy: String
    var userId: String

    func toEntity() -> TaskEntity {
        return TaskEntity(
            id: id ?? UUID().uuidString,
            title: title,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdBy: createdBy,
            userId: userId
        )
    }

    static func fromEntity(_ entity: TaskEntity) -> TaskDTO {
        return TaskDTO(
            id: entity.id,
            title: entity.title,
            isCompleted: entity.isCompleted,
            completedAt: entity.completedAt,
            createdBy: entity.createdBy,
            userId: entity.userId
        )
    }
}
