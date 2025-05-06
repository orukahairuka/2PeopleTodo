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

    private let firestoreService = TaskFirestoreService()
    private var listener: ListenerRegistration?

    var filteredTasks: [Task] {
        guard let selectedUser = selectedUser else { return tasks }
        return tasks.filter { $0.createdBy == selectedUser }
    }

    var filteredCompletedTasks: [Task] {
        guard let selectedUser = selectedUser else { return completedTasks }
        return completedTasks.filter { $0.createdBy == selectedUser }
    }

    var sortedFilteredCompletedTasks: [Task] {
        let filtered = selectedUser == nil ? completedTasks : completedTasks.filter { $0.createdBy == selectedUser }
        return filtered.sorted {
            ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
        }
    }

    func fetchTasks(groupCode: String) {
        listener?.remove()
        listener = firestoreService.listenTasks(groupCode: groupCode) { [weak self] allTasks in
            self?.tasks = allTasks.filter { !$0.isCompleted }
            self?.completedTasks = allTasks.filter { $0.isCompleted }
            self?.updateAllUsers()
        }
    }

    func addTask(title: String, groupCode: String, createdBy: String, userId: String) {
        let newTask = Task(id: UUID().uuidString, title: title, isCompleted: false, completedAt: nil, createdBy: createdBy, userId: userId)
        firestoreService.addTask(newTask, groupCode: groupCode)
    }

    func completeTask(_ task: Task, groupCode: String) {
        var updated = task
        updated.isCompleted = true
        updated.completedAt = Date()
        firestoreService.updateTask(updated, groupCode: groupCode)
    }

    func deleteTask(_ task: Task, groupCode: String) {
        firestoreService.deleteTask(task, groupCode: groupCode)
    }

    private func updateAllUsers() {
        let users = Set(tasks.map { $0.createdBy } + completedTasks.map { $0.createdBy })
        allUsers = Array(users).sorted()
    }
}
