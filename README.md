# 🤖 Claude Code Team Doc Builder

Claudeマルチエージェントシステムによるドキュメント自動生成ツール(Claude Code単体）

## 🎯 システム概要

複数のClaudeエージェントが連携して、プロジェクトの要件定義書・仕様書・市場調査レポートを自動生成します。
PRESIDENT → BOSS → Workers の階層型マネジメントシステムを実装。

### 👥 エージェント構成

```
📊 PRESIDENT セッション (1ペイン)
└── PRESIDENT: プロジェクト統括責任者・戦略決定

📊 multiagent セッション (4ペイン)  
├── boss1: プロジェクトマネージャー・進捗管理
├── worker1: 要件定義担当エンジニア
├── worker2: 仕様書作成担当エンジニア
└── worker3: 市場調査・品質レビュー担当
```

## 🚀 クイックスタート

### 0. リポジトリのクローン

```bash
git clone https://github.com/cruzyjapan/Claude-Code-Team-Doc-Builder-Stand-Alone.git
cd Claude-Code-Team-Doc-Builder
```

### 1. tmux環境構築

⚠️ **注意**: 既存の `multiagent` と `president` セッションがある場合は自動的に削除されます。

```bash
chmod +x setup.sh
./setup.sh
```

### 2. セッションアタッチ

```bash
# マルチエージェント確認
tmux attach-session -t multiagent

# プレジデント確認（別ターミナルで）
tmux attach-session -t president
```

### 3. Claude Code起動

**手順1: President認証**
```bash
# まずPRESIDENTで認証を実施
tmux send-keys -t president 'claude --dangerously-skip-permissions' C-m
```
認証プロンプトに従って許可を与えてください。

**手順2: Multiagent一括起動**
```bash
# 認証完了後、multiagentセッションを一括起動 （↑のpresidentターミナルで以下、Claudeに渡す）
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude --dangerously-skip-permissions' C-m; done
```

### 4. プロジェクト実行

PRESIDENTセッションで直接入力：
```
あなたはpresidentです。[プロジェクト名] 開発プロジェクト開始指示
```

**例**:
```
あなたはpresidentです。OpenAI APIチャットアプリ開発プロジェクト開始指示
```

## 📜 指示書について

各エージェントの役割別指示書：
- **PRESIDENT**: `instructions/president.md`
- **boss1**: `instructions/boss.md` 
- **worker1,2,3**: `instructions/worker.md`

**Claude Code参照**: `CLAUDE.md` でシステム構造を確認

**要点:**
- **PRESIDENT**: プロジェクト開始指示 → boss1に指示送信
- **boss1**: PRESIDENT指示受信 → workers全員に作業分担 → 完了報告
- **workers**: 
  - worker1: 要件定義書作成
  - worker2: 仕様書作成  
  - worker3: 市場調査レポート作成

## 🎬 期待される動作フロー

```
1. PRESIDENT → boss1: "[プロジェクト名] 開発プロジェクト開始指示"
2. boss1 → workers: 各エージェントに専門分野の作業指示
   - worker1: 要件定義担当
   - worker2: 仕様書作成担当  
   - worker3: 市場調査・レビュー担当
3. workers → deliverables/に成果物生成 → boss1: "作業完了報告"
4. boss1 → PRESIDENT: "全員完了しました"
```

## 📁 成果物

プロジェクト完了後、`deliverables/` フォルダに以下が生成されます：
- `requirements_definition.md` - 詳細な要件定義書
- `[Project]_Specification.md` - 技術仕様書
- `market_research_report.md` - 市場分析レポート

## 🔧 手動操作

### agent-send.shを使った送信

```bash
# 基本送信
./agent-send.sh [エージェント名] [メッセージ]

# 例
./agent-send.sh boss1 "緊急タスクです"
./agent-send.sh worker1 "作業完了しました"
./agent-send.sh president "最終報告です"

# エージェント一覧確認
./agent-send.sh --list
```

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "boss1" logs/send_log.txt

# 成果物確認
ls -la deliverables/
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t multiagent
tmux list-panes -t president
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t multiagent
tmux kill-session -t president

# ログ・成果物クリア
rm -f logs/send_log.txt
rm -f deliverables/*.md

# 再構築（自動クリア付き）
./setup.sh
```

---

🚀 **Claude Code Team Doc Builder でプロジェクトドキュメントを自動生成しよう！** 🤖✨ 