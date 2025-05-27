//
//  CompletedTasksView.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//
import SwiftUI


struct CompletedTasksView: View {
    @ObservedObject var viewModel: CompletedTasksViewModel

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Color.white
                    .frame(height: 10)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 5)
                        .offset(y: 5)
                    )
                ScrollView {
                    VStack(spacing: 20) {
                        filterSection
                        completedTasksSection
                    }
                    .padding()
                }

                Color.white
                    .frame(height: 10)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.gray.opacity(0.2)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 5)
                        .offset(y: -5)
                    )
            }
        }
        .navigationTitle("完了したタスク")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 以降のコード（filterSection, completedTasksSectionなど）はそのままでOK
    // ✅ これらは struct の中にある必要がある
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ユーザーでフィルター")
                .font(.headline)

            Picker("ユーザーを選択", selection: $viewModel.selectedUser) {
                Text("すべて").tag(nil as String?)
                ForEach(viewModel.allUsers, id: \.self) { user in
                    Text(user).tag(user as String?)
                }
            }
            .pickerStyle(.segmented)
        }
    }


    private var completedTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.sortedFilteredCompletedTasks.isEmpty {
                Text("該当する完了タスクがありません。")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.sortedFilteredCompletedTasks, id: \.id) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Text(task.createdBy)
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }


}
