#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# モード設定 (環境変数CLAUDE_MODEで制御、デフォルトはdemo)
MODE="${CLAUDE_MODE:-demo}"

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    if [ "$MODE" = "production" ]; then
        # プロダクションモード
        case "$1" in
            "president") echo "president" ;;
            "pmo") echo "multiagent:0.0" ;;
            "worker1-requirements") echo "multiagent:0.1" ;;
            "worker2-specification") echo "multiagent:0.2" ;;
            "worker3-research") echo "multiagent:0.3" ;;
            *) echo "" ;;
        esac
    else
        # デモモード
        case "$1" in
            "president") echo "president" ;;
            "boss1") echo "multiagent:0.0" ;;
            "worker1") echo "multiagent:0.1" ;;
            "worker2") echo "multiagent:0.2" ;;
            "worker3") echo "multiagent:0.3" ;;
            *) echo "" ;;
        esac
    fi
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list
  $0 --mode           現在のモードを表示
  
環境変数:
  CLAUDE_MODE=demo|production (デフォルト: demo)

EOF
    
    if [ "$MODE" = "production" ]; then
        cat << EOF
利用可能エージェント (プロダクションモード):
  president            - プロジェクト統括責任者
  pmo                  - プロジェクト管理オフィス
  worker1-requirements - 要件定義担当
  worker2-specification - 仕様書作成担当
  worker3-research     - 市場調査・レビュー担当
EOF
    else
        cat << EOF
利用可能エージェント (デモモード):
  president - プロジェクト統括責任者
  boss1     - チームリーダー
  worker1   - 実行担当者A
  worker2   - 実行担当者B
  worker3   - 実行担当者C
EOF
    fi
    
    cat << EOF

使用例:
  $0 president "プロジェクト開始指示"
  $0 pmo "プロジェクト進捗確認"
  $0 worker1-requirements "要件定義完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント (モード: $MODE):"
    echo "=========================="
    
    if [ "$MODE" = "production" ]; then
        echo "  president            → president:0     (プロジェクト統括責任者)"
        echo "  pmo                  → multiagent:0.0  (プロジェクト管理オフィス)"
        echo "  worker1-requirements → multiagent:0.1  (要件定義担当)"
        echo "  worker2-specification → multiagent:0.2  (仕様書作成担当)" 
        echo "  worker3-research     → multiagent:0.3  (市場調査・レビュー担当)"
    else
        echo "  president → president:0     (プロジェクト統括責任者)"
        echo "  boss1     → multiagent:0.0  (チームリーダー)"
        echo "  worker1   → multiagent:0.1  (実行担当者A)"
        echo "  worker2   → multiagent:0.2  (実行担当者B)" 
        echo "  worker3   → multiagent:0.3  (実行担当者C)"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    # --modeオプション
    if [[ "$1" == "--mode" ]]; then
        echo "現在のモード: $MODE"
        echo "変更するには: export CLAUDE_MODE=production または export CLAUDE_MODE=demo"
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 