#!/bin/bash

# 🔍 Multi-Agent System モニタリングツール

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# モード取得
MODE="${CLAUDE_MODE:-demo}"

# ヘッダー表示
show_header() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  Multi-Agent System Monitor${NC}"
    echo -e "${BLUE}  Mode: ${YELLOW}$MODE${NC}"
    echo -e "${BLUE}  Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo
}

# エージェント状態確認
check_agent_status() {
    local session="$1"
    local pane="$2"
    local agent_name="$3"
    
    if tmux has-session -t "$session" 2>/dev/null; then
        if [ -n "$pane" ]; then
            if tmux list-panes -t "$session" | grep -q "$pane"; then
                echo -e "${GREEN}✓ $agent_name${NC} - Active"
            else
                echo -e "${RED}✗ $agent_name${NC} - Pane not found"
            fi
        else
            echo -e "${GREEN}✓ $agent_name${NC} - Active"
        fi
    else
        echo -e "${RED}✗ $agent_name${NC} - Session not found"
    fi
}

# エージェント一覧表示
show_agents_status() {
    echo -e "${YELLOW}📊 Agent Status:${NC}"
    echo "------------------------"
    
    if [ "$MODE" = "production" ]; then
        check_agent_status "president" "" "President"
        check_agent_status "multiagent" "0.0" "PMO"
        check_agent_status "multiagent" "0.1" "Worker1 (Requirements)"
        check_agent_status "multiagent" "0.2" "Worker2 (Specification)"
        check_agent_status "multiagent" "0.3" "Worker3 (Research)"
    else
        check_agent_status "president" "" "President"
        check_agent_status "multiagent" "0.0" "Boss1"
        check_agent_status "multiagent" "0.1" "Worker1"
        check_agent_status "multiagent" "0.2" "Worker2"
        check_agent_status "multiagent" "0.3" "Worker3"
    fi
    echo
}

# 最近のメッセージ表示
show_recent_messages() {
    echo -e "${YELLOW}📨 Recent Messages:${NC}"
    echo "------------------------"
    
    if [ -f logs/send_log.txt ]; then
        tail -n 10 logs/send_log.txt | while IFS= read -r line; do
            if [[ $line == *"SENT"* ]]; then
                echo -e "${GREEN}$line${NC}"
            else
                echo "$line"
            fi
        done
    else
        echo "No message logs found"
    fi
    echo
}

# ディレクトリ状態表示
show_directory_status() {
    echo -e "${YELLOW}📁 Directory Status:${NC}"
    echo "------------------------"
    
    # デモモードファイル
    if [ "$MODE" = "demo" ]; then
        echo -e "${BLUE}Demo Instructions:${NC}"
        for file in instructions/*.md; do
            if [ -f "$file" ]; then
                echo "  ✓ $(basename "$file")"
            fi
        done
    fi
    
    # プロダクションモードファイル
    if [ "$MODE" = "production" ]; then
        echo -e "${BLUE}Production Roles:${NC}"
        for dir in roles/*/; do
            if [ -d "$dir" ]; then
                role_name=$(basename "$dir")
                echo "  📂 $role_name"
                for file in "$dir"*.md; do
                    if [ -f "$file" ]; then
                        echo "    ✓ $(basename "$file")"
                    fi
                done
            fi
        done
    fi
    
    # 成果物
    echo -e "\n${BLUE}Deliverables:${NC}"
    if [ -d deliverables ] && [ "$(ls -A deliverables 2>/dev/null)" ]; then
        find deliverables -type f -name "*.md" -o -name "*.txt" | while read -r file; do
            echo "  📄 $file"
        done
    else
        echo "  (empty)"
    fi
    
    # 一時ファイル
    echo -e "\n${BLUE}Temporary Files:${NC}"
    if [ -d tmp ] && [ "$(ls -A tmp 2>/dev/null)" ]; then
        ls -la tmp/ | grep -v "^d" | grep -v "^total" | awk '{print "  " $9}'
    else
        echo "  (empty)"
    fi
    echo
}

# メイン処理
main() {
    # 引数処理
    case "$1" in
        "--once"|"-o")
            show_header
            show_agents_status
            show_recent_messages
            show_directory_status
            ;;
        "--help"|"-h")
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --once, -o    Show status once and exit"
            echo "  --help, -h    Show this help message"
            echo "  (no options)  Continuous monitoring (refresh every 5 seconds)"
            ;;
        *)
            # 継続的なモニタリング
            while true; do
                show_header
                show_agents_status
                show_recent_messages
                show_directory_status
                echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
                sleep 5
            done
            ;;
    esac
}

main "$@"