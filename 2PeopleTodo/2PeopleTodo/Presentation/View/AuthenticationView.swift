import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case username
        case groupCode
    }

    var isInputValid: Bool {
        !viewModel.username.isEmpty && !viewModel.groupCode.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // タイトル
                Text("グループTodoへようこそ")
                    .font(.title)
                    .bold()
                    .padding(.top)

                // 補足説明
                Text("友達と同じグループコードを入力してタスクを共有しよう。\nコードが存在しない場合は自動で新規作成されます。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // ユーザー名
                TextField("あなたの名前", text: $viewModel.username)
                    .focused($focusedField, equals: .username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // グループコード
                TextField("グループコード（英数字）", text: $viewModel.groupCode)
                    .focused($focusedField, equals: .groupCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                // エラー表示
                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                // 実行ボタン
                Button(action: {
                    viewModel.joinOrCreateGroup() // 既存のロジックは変更せず
                }) {
                    Text("グループに参加 / 作成")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isInputValid)
                .padding(.horizontal)

                // 再試行（失敗時のみ表示）
                if viewModel.errorMessage != nil {
                    Button("サインインを再試行") {
                        viewModel.signInAnonymously()
                    }
                    .font(.footnote)
                    .padding(.top, 8)
                }

                Spacer()

                // 非表示の画面遷移リンク
                NavigationLink(
                    destination: MainView(
                        viewModel: MainViewModel(
                            groupCode: viewModel.groupCode,
                            username: viewModel.username,
                            userId: viewModel.userId
                        )
                    ),
                    isActive: $viewModel.shouldNavigate
                ) {
                    EmptyView()
                }

            }
            .padding()
            .onAppear {
                viewModel.signInAnonymously()
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
}

