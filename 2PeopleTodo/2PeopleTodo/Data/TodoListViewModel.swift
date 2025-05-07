//
//  TodoListViewModel.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import Foundation
import FirebaseFirestore

/// タスクの一覧・追加・完了・削除を扱うViewModel
/// Firestoreへのアクセスは TaskRepositoryProtocol に依存している
class TodoListViewModel: ObservableObject {
    @Published var tasks: [Task] = [] // 未完了のタスク一覧
    @Published var completedTasks: [Task] = []// 完了済みのタスク一覧
    @Published var selectedUser: String?// 選択されたユーザー名（タスクをフィルターするために使用）
    @Published var allUsers: [String] = []// 登録済みの全ユーザー（`createdBy`の一覧）

    private let taskRepository: TaskRepositoryProtocol// タスク取得・保存のためのリポジトリ
    private var listener: ListenerRegistration?// Firestore のリアルタイムリスナー（監視を解除するために保持）
    private let fetchTasksUseCase: FetchTasksUseCaseProtocol
    private let addTaskUseCase: AddTaskUseCaseProtocol



    // 初期化時にリポジトリを注入（デフォルトは TaskRepository）
    init(
        taskRepository: TaskRepositoryProtocol = TaskRepository(),
        fetchTasksUseCase: FetchTasksUseCaseProtocol? = nil,
        addTaskUseCase: AddTaskUseCaseProtocol? = nil
    ) {
        self.taskRepository = taskRepository
        self.fetchTasksUseCase = fetchTasksUseCase ?? FetchTasksUseCase(repository: taskRepository)
        self.addTaskUseCase = addTaskUseCase ?? AddTaskUseCase(repository: taskRepository)
    }

    // 選択されたユーザーの未完了タスクのみを返す
    var filteredTasks: [Task] {
        guard let selectedUser = selectedUser else { return tasks }
        return tasks.filter { $0.createdBy == selectedUser }
    }

    // 選択されたユーザーの完了済みタスクのみを返す
    var filteredCompletedTasks: [Task] {
        guard let selectedUser = selectedUser else { return completedTasks }
        return completedTasks.filter { $0.createdBy == selectedUser }
    }

    // 選択ユーザーの完了済みタスクを完了日時の降順で返す
    var sortedFilteredCompletedTasks: [Task] {
        let filtered = selectedUser == nil
        ? completedTasks
        : completedTasks.filter { $0.createdBy == selectedUser }
        return filtered.sorted {
            ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
        }
    }

    // Firestoreからタスクをリアルタイムで取得・監視
    func fetchTasks(groupCode: String) {
        listener?.remove()
        listener = fetchTasksUseCase.execute(groupCode: groupCode) { [weak self] allTasks in
            self?.tasks = allTasks.filter { !$0.isCompleted }
            self?.completedTasks = allTasks.filter { $0.isCompleted }
            self?.updateAllUsers()
        }
    }

    // 新しいタスクを作成して保存
    func addTask(title: String, groupCode: String, createdBy: String, userId: String) {
        addTaskUseCase.execute(title: title, groupCode: groupCode, createdBy: createdBy, userId: userId)
    }

    
    // 指定されたタスクを完了状態に更新
    func completeTask(_ task: Task, groupCode: String) {
        var updated = task
        updated.isCompleted = true
        updated.completedAt = Date()
        taskRepository.updateTask(updated, groupCode: groupCode)
    }

    // タスクを削除
    func deleteTask(_ task: Task, groupCode: String) {
        taskRepository.deleteTask(task, groupCode: groupCode)
    }

    // タスクに関わった全ユーザー名を更新（重複なしでソート）
    private func updateAllUsers() {
        let users = Set(tasks.map { $0.createdBy } + completedTasks.map { $0.createdBy })
        allUsers = Array(users).sorted()
    }
}

