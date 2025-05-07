//
//  TaskRepositoryProtocol.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/06.
//

import Foundation
import FirebaseFirestore

/// タスクデータへのアクセス手段を定義するプロトコル
protocol TaskRepositoryProtocol {
    /// 指定されたグループのタスク一覧をリアルタイムで取得
    func observeTasks(groupCode: String, onUpdate: @escaping ([TaskEntity]) -> Void) -> ListenerRegistration

    /// タスクを追加する
    func addTask(_ task: TaskEntity, groupCode: String)

    /// タスクを更新する（完了・未完了など）
    func updateTask(_ task: TaskEntity, groupCode: String)

    /// タスクを削除する
    func deleteTask(_ task: TaskEntity, groupCode: String)
}
