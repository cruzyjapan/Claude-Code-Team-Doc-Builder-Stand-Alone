#!/bin/bash

# 🧹 Multi-Agent System クリーンアップツール

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# デフォルト設定
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-7}
ARCHIVE_DIR="archives"

# ヘルプ表示
show_help() {
    cat << EOF
Multi-Agent System Cleanup Tool

使用方法:
  $0 [options] [command]

コマンド:
  logs      古いログファイルをクリーンアップ
  tmp       一時ファイルをクリーンアップ
  archive   成果物をアーカイブ
  all       すべてのクリーンアップを実行

オプション:
  -d, --days N    ログ保持日数 (デフォルト: $LOG_RETENTION_DAYS)
  -f, --force     確認なしで実行
  -h, --help      このヘルプを表示

例:
  $0 logs                # 7日以上前のログを削除
  $0 -d 30 logs         # 30日以上前のログを削除
  $0 -f all             # 確認なしですべてクリーンアップ
EOF
}

# 確認プロンプト
confirm() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    echo -e "${YELLOW}$1${NC}"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# ログクリーンアップ
cleanup_logs() {
    echo -e "${YELLOW}📋 ログファイルのクリーンアップ${NC}"
    echo "------------------------"
    
    if [ ! -d logs ]; then
        echo "logsディレクトリが存在しません"
        return
    fi
    
    # 古いログファイルを検索
    old_files=$(find logs -name "*.txt" -type f -mtime +$LOG_RETENTION_DAYS 2>/dev/null)
    
    if [ -z "$old_files" ]; then
        echo -e "${GREEN}✓ 削除対象のログファイルはありません${NC}"
        return
    fi
    
    echo "以下のファイルが削除対象です:"
    echo "$old_files"
    
    if confirm "これらのファイルを削除しますか？"; then
        echo "$old_files" | while read -r file; do
            if [ -f "$file" ]; then
                rm "$file"
                echo -e "${GREEN}✓ 削除: $file${NC}"
            fi
        done
    fi
}

# 一時ファイルクリーンアップ
cleanup_tmp() {
    echo -e "${YELLOW}🗑️  一時ファイルのクリーンアップ${NC}"
    echo "------------------------"
    
    if [ ! -d tmp ]; then
        echo "tmpディレクトリが存在しません"
        return
    fi
    
    # tmpディレクトリ内のファイル一覧
    tmp_files=$(find tmp -type f 2>/dev/null)
    
    if [ -z "$tmp_files" ]; then
        echo -e "${GREEN}✓ 一時ファイルはありません${NC}"
        return
    fi
    
    echo "以下のファイルが削除対象です:"
    echo "$tmp_files"
    
    if confirm "これらのファイルを削除しますか？"; then
        echo "$tmp_files" | while read -r file; do
            if [ -f "$file" ]; then
                rm "$file"
                echo -e "${GREEN}✓ 削除: $file${NC}"
            fi
        done
    fi
}

# 成果物アーカイブ
archive_deliverables() {
    echo -e "${YELLOW}📦 成果物のアーカイブ${NC}"
    echo "------------------------"
    
    if [ ! -d deliverables ] || [ -z "$(ls -A deliverables 2>/dev/null)" ]; then
        echo "アーカイブする成果物がありません"
        return
    fi
    
    # アーカイブディレクトリ作成
    mkdir -p "$ARCHIVE_DIR"
    
    # タイムスタンプ付きアーカイブ名
    timestamp=$(date '+%Y%m%d_%H%M%S')
    archive_name="${ARCHIVE_DIR}/deliverables_${timestamp}.tar.gz"
    
    echo "成果物をアーカイブします: $archive_name"
    
    if confirm "成果物をアーカイブしますか？"; then
        tar -czf "$archive_name" -C deliverables . 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ アーカイブ作成完了: $archive_name${NC}"
            
            # アーカイブ後の元ファイル削除
            if confirm "アーカイブした元ファイルを削除しますか？"; then
                rm -rf deliverables/*
                echo -e "${GREEN}✓ 元ファイルを削除しました${NC}"
            fi
        else
            echo -e "${RED}✗ アーカイブ作成に失敗しました${NC}"
        fi
    fi
}

# セッションリセット（実験的機能）
reset_sessions() {
    echo -e "${YELLOW}🔄 tmuxセッションのリセット${NC}"
    echo "------------------------"
    echo -e "${RED}警告: この操作はすべてのエージェントセッションを終了します${NC}"
    
    if confirm "本当にすべてのセッションをリセットしますか？"; then
        # presidentセッション終了
        if tmux has-session -t president 2>/dev/null; then
            tmux kill-session -t president
            echo -e "${GREEN}✓ presidentセッションを終了しました${NC}"
        fi
        
        # multiagentセッション終了
        if tmux has-session -t multiagent 2>/dev/null; then
            tmux kill-session -t multiagent
            echo -e "${GREEN}✓ multiagentセッションを終了しました${NC}"
        fi
        
        echo -e "${GREEN}✓ セッションのリセットが完了しました${NC}"
        echo "新しいセッションを開始するには ./setup.sh を実行してください"
    fi
}

# すべてクリーンアップ
cleanup_all() {
    echo -e "${YELLOW}🧹 すべてのクリーンアップを実行${NC}"
    echo "==============================="
    echo
    
    cleanup_logs
    echo
    cleanup_tmp
    echo
    archive_deliverables
    echo
    
    echo -e "${GREEN}✓ すべてのクリーンアップが完了しました${NC}"
}

# メイン処理
main() {
    # デフォルト値
    FORCE=false
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--days)
                LOG_RETENTION_DAYS="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            logs)
                cleanup_logs
                exit 0
                ;;
            tmp)
                cleanup_tmp
                exit 0
                ;;
            archive)
                archive_deliverables
                exit 0
                ;;
            reset)
                reset_sessions
                exit 0
                ;;
            all)
                cleanup_all
                exit 0
                ;;
            *)
                echo "不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 引数なしの場合
    show_help
}

main "$@"