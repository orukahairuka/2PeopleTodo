//
//  TaskEntity.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

// TaskEntity.swift

import Foundation

/// アプリの中で使う純粋なタスク情報
struct TaskEntity: Identifiable, Equatable {
    let id: String
    let title: String
    let isCompleted: Bool
    let completedAt: Date?
    let createdBy: String
    let userId: String
}

