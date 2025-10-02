# 2PeopleTodo

2人で共有できるシンプルなTodoアプリ（iOS）です。グループコードで共有し、リアルタイムでタスクを同期します。

## 主な機能

- **グループでタスク共有**: グループコードで2人がタスクリストを共有
- **リアルタイム同期**: Firebase Firestoreを使用してタスクをリアルタイム同期
- **匿名認証**: Firebase Anonymous Authenticationでシンプルにログイン
- **タスク管理**: タスクの追加、完了、削除が可能
- **完了済みタスク表示**: 完了したタスクを別タブで確認

## 技術スタック

- **言語**: Swift
- **フレームワーク**: SwiftUI
- **バックエンド**: Firebase (Authentication, Firestore)
- **アーキテクチャ**: MVVM + Clean Architecture (Entity, UseCase, Repository, ViewModel)

## プロジェクト構成

```
2PeopleTodo/
├── Entity/              # ドメインエンティティ
│   └── Task/           # タスク関連のエンティティ（TaskEntity, TaskDTO）
├── Models/             # アプリケーションモデル
│   ├── AppState.swift
│   ├── AuthManager.swift
│   └── GroupManager.swift
├── Presentation/       # プレゼンテーション層
│   ├── View/          # SwiftUI Views
│   └── ViewModel/     # ViewModels
├── Protocol/          # プロトコル定義
├── Repository/        # データアクセス層
├── Service/           # 外部サービス（Firebase等）
└── UseCase/           # ビジネスロジック
```

## セットアップ

1. Firebase プロジェクトを作成し、`GoogleService-Info.plist` をプロジェクトに追加
2. Xcode でプロジェクトを開く
3. 依存関係を解決（Firebase SDK）
4. ビルド & 実行

## 使い方

1. アプリを起動すると匿名認証が実行されます
2. ユーザー名とグループコードを入力
3. グループコードが存在しない場合は新規作成、存在する場合は参加
4. タスク一覧でタスクを追加・管理
5. 完了したタスクは「完了済み」タブで確認できます

## テスト

Unit Tests を `PeopleTodoTests/` に配置しています。主に UseCase 層のテストを実装。
