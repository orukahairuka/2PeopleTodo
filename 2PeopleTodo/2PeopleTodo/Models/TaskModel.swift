//
//  TaskModel.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import Foundation

struct Task: Identifiable, Codable {
    var id: String
    var title: String
    var isCompleted: Bool
    var completedAt: Date?
    var createdBy: String
}
