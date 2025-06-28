#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# インスタンス番号を生成（既存のセッション数をカウント）
INSTANCE_NUM=$(($(tmux list-sessions 2>/dev/null | grep -c "^multiagent" || echo 0) + 1))
echo "インスタンス番号: $INSTANCE_NUM"

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：boss1 + worker1,2,3）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s multiagent -n "agents"

# ペイン境界線のスタイル設定（デフォルト黒背景）
tmux set-option -t multiagent pane-border-style 'fg=colour245'
tmux set-option -t multiagent pane-active-border-style 'fg=colour250'

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
tmux select-pane -t "multiagent:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "multiagent:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("boss1" "worker1" "worker2" "worker3")
PANE_DESCRIPTIONS=("ドキュメントリーダー：構成管理・レビュー" "技術ライター：API・設計文書作成" "コンテンツ編集者：ユーザーガイド作成" "品質管理者：文書校正・整合性確認")
PANE_COLORS=("31" "34" "32" "33")  # 31=赤, 34=青, 32=緑, 33=黄

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
    
    # 作業ディレクトリ設定
    tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
    
    # カラープロンプト設定（各エージェントに異なる色）
    tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;${PANE_COLORS[$i]}m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    
    # 枠線色設定（デフォルト黒背景、枠線のみ色分け）
    case $i in
        0) # boss1: 赤枠線
            tmux select-pane -t "multiagent:0.$i" -P 'fg=colour196'
            ;;
        1) # worker1: 青枠線
            tmux select-pane -t "multiagent:0.$i" -P 'fg=colour39'
            ;;
        2) # worker2: 緑枠線
            tmux select-pane -t "multiagent:0.$i" -P 'fg=colour46'
            ;;
        3) # worker3: 黄枠線
            tmux select-pane -t "multiagent:0.$i" -P 'fg=colour226'
            ;;
    esac
    
    # ターミナルヘッダー表示（色付きボックス）
    tmux send-keys -t "multiagent:0.$i" "clear" C-m
    
    # 各エージェント用の色付きボックス
    case $i in
        0) # boss1: 赤色ボックス
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;31m╔════════════════════════════════════════╗\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;31m║\033[0m \033[1;31m${PANE_TITLES[$i]} エージェント\033[0m \033[1;31m║\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;31m╠════════════════════════════════════════╣\033[0m'" C-m
            ;;
        1) # worker1: 青色ボックス
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;34m╔════════════════════════════════════════╗\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;34m║\033[0m \033[1;34m${PANE_TITLES[$i]} エージェント\033[0m \033[1;34m║\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;34m╠════════════════════════════════════════╣\033[0m'" C-m
            ;;
        2) # worker2: 緑色ボックス
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;32m╔════════════════════════════════════════╗\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;32m║\033[0m \033[1;32m${PANE_TITLES[$i]} エージェント\033[0m \033[1;32m║\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;32m╠════════════════════════════════════════╣\033[0m'" C-m
            ;;
        3) # worker3: 黄色ボックス
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;33m╔════════════════════════════════════════╗\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;33m║\033[0m \033[1;33m${PANE_TITLES[$i]} エージェント\033[0m \033[1;33m║\033[0m'" C-m
            tmux send-keys -t "multiagent:0.$i" "echo '\033[1;33m╠════════════════════════════════════════╣\033[0m'" C-m
            ;;
    esac
    
    tmux send-keys -t "multiagent:0.$i" "echo '\033[1;${PANE_COLORS[$i]}m║\033[0m ${PANE_DESCRIPTIONS[$i]} \033[1;${PANE_COLORS[$i]}m║\033[0m'" C-m
    tmux send-keys -t "multiagent:0.$i" "echo '\033[1;${PANE_COLORS[$i]}m╚════════════════════════════════════════╝\033[0m'" C-m
    tmux send-keys -t "multiagent:0.$i" "echo ''" C-m
    
    # ターミナル下部に説明を表示する関数を定義（インスタンス番号付き）
    tmux send-keys -t "multiagent:0.$i" "show_terminal_info() { echo -e '\n\033[1;90m────────────────────────────────────────\033[0m'; echo -e '\033[1;${PANE_COLORS[$i]}m${PANE_TITLES[$i]}-$INSTANCE_NUM\033[0m: ${PANE_DESCRIPTIONS[$i]}'; echo -e '\033[1;90m────────────────────────────────────────\033[0m'; }" C-m
    
    # プロンプトコマンドを設定（コマンド実行後に自動的に説明を表示）
    tmux send-keys -t "multiagent:0.$i" "export PROMPT_COMMAND='show_terminal_info'" C-m
    
    # 初回表示
    tmux send-keys -t "multiagent:0.$i" "show_terminal_info" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（1ペイン）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s president
tmux send-keys -t president "cd $(pwd)" C-m
tmux send-keys -t president "export PS1='(\[\033[1;36m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m

# 枠線色設定（デフォルト黒背景、シアン枠線）
tmux select-pane -t "president:0" -P 'fg=colour51'

# ターミナルヘッダー表示（シアン色ボックス）
tmux send-keys -t president "clear" C-m
tmux send-keys -t president "echo '\033[1;36m╔════════════════════════════════════════════════╗\033[0m'" C-m
tmux send-keys -t president "echo '\033[1;36m║\033[0m \033[1;36mPRESIDENT\033[0m - ドキュメント統括責任者 \033[1;36m║\033[0m'" C-m
tmux send-keys -t president "echo '\033[1;36m╠════════════════════════════════════════════════╣\033[0m'" C-m
tmux send-keys -t president "echo '\033[1;36m║\033[0m 文書構成決定・品質基準設定・最終承認 \033[1;36m║\033[0m'" C-m
tmux send-keys -t president "echo '\033[1;36m║\033[0m 各エージェント間の調整・スタイルガイド管理 \033[1;36m║\033[0m'" C-m
tmux send-keys -t president "echo '\033[1;36m╚════════════════════════════════════════════════╝\033[0m'" C-m
tmux send-keys -t president "echo ''" C-m

# ターミナル下部に説明を表示する関数を定義（インスタンス番号付き）
tmux send-keys -t president "show_terminal_info() { echo -e '\n\033[1;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m'; echo -e '\033[1;36mPRESIDENT-$INSTANCE_NUM\033[0m: ドキュメント統括 | 品質管理 | 最終承認'; echo -e '\033[1;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m'; }" C-m

# プロンプトコマンドを設定
tmux send-keys -t president "export PROMPT_COMMAND='show_terminal_info'" C-m

# 初回表示
tmux send-keys -t president "show_terminal_info" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: boss1     (チームリーダー)"
echo "    Pane 1: worker1   (実行担当者A)"
echo "    Pane 2: worker2   (実行担当者B)"
echo "    Pane 3: worker3   (実行担当者C)"
echo ""
echo "  presidentセッション（1ペイン）:"
echo "    Pane 0: PRESIDENT (プロジェクト統括)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # マルチエージェント確認"
echo "     tmux attach-session -t president    # プレジデント確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: President認証"
echo "     tmux send-keys -t president 'claude' C-m"
echo "     # 手順2: 認証後、multiagent一括起動"
echo "     for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude --dangerously-skip-permissions' C-m; done"
echo ""
echo "  3. 📜 指示書確認:"
echo "     PRESIDENT: instructions/president.md"
echo "     boss1: instructions/boss.md"
echo "     worker1,2,3: instructions/worker.md"
echo "     システム構造: CLAUDE.md"
echo ""
echo "  4. 🎯 デモ実行: PRESIDENTに「あなたはpresidentです。指示書に従って」と入力" 