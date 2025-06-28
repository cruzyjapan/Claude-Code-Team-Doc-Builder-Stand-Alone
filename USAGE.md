# Multi-Agent System 使用ガイド

## 🚀 クイックスタート

### 1. 環境セットアップ
```bash
./setup.sh
```

### 2. モード選択

#### デモモード（デフォルト）
簡単なHello Worldデモを実行
```bash
export CLAUDE_MODE=demo
```

#### プロダクションモード
本格的なプロジェクト管理システム
```bash
export CLAUDE_MODE=production
```

### 3. エージェント間通信
```bash
# 現在のモードを確認
./agent-send.sh --mode

# 利用可能なエージェントを表示
./agent-send.sh --list

# メッセージ送信
./agent-send.sh [エージェント名] "[メッセージ]"
```

## 📊 システムモニタリング

### リアルタイムモニタリング
```bash
./monitor.sh
```

### ワンショット表示
```bash
./monitor.sh --once
```

## 🧹 メンテナンス

### ログクリーンアップ
```bash
# 7日以上前のログを削除
./cleanup.sh logs

# 30日以上前のログを削除
./cleanup.sh -d 30 logs
```

### 一時ファイル削除
```bash
./cleanup.sh tmp
```

### 成果物アーカイブ
```bash
./cleanup.sh archive
```

### 全クリーンアップ
```bash
./cleanup.sh all
```

## 🏗️ ディレクトリ構造

### デモモード
```
instructions/
├── president.md    # プレジデント指示書
├── boss.md         # ボス指示書
└── worker.md       # ワーカー指示書
```

### プロダクションモード
```
roles/
├── President/                          # 統括責任者
├── PMO/                               # プロジェクト管理
├── Worker1-RequirementsDefinition/    # 要件定義
├── Worker2-SpecificationCreation/     # 仕様書作成
└── Worker3-MarketResearchReview/      # 市場調査・レビュー
```

## 🔄 ワークフロー

### デモモードフロー
1. President → Boss1 → Workers (1,2,3)
2. Workers → Boss1 → President

### プロダクションモードフロー
1. President → PMO
2. PMO → Workers (要件定義、仕様書、市場調査)
3. Workers → PMO → President

## 📝 設定ファイル

### roles.yaml
エージェントの役割とセッション情報を定義

### 環境変数
- `CLAUDE_MODE`: 動作モード (demo/production)
- `LOG_RETENTION_DAYS`: ログ保持日数

## 🛠️ トラブルシューティング

### セッションが見つからない
```bash
# セッション状態確認
tmux ls

# セットアップ再実行
./setup.sh
```

### メッセージが送信されない
```bash
# エージェント状態確認
./monitor.sh --once

# ログ確認
tail -f logs/send_log.txt
```

### セッションリセット
```bash
# 全セッション終了（注意）
./cleanup.sh reset
```