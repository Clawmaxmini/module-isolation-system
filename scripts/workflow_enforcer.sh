#!/bin/bash
# Enforce 5-step module isolation workflow

CURRENT_MODULE_FILE=".current_module"
MODULE_SWITCH_HISTORY=".module_switch_history"

# Source the judge_module function
source "$(dirname "$0")/judge_module.sh"

# Main workflow function
process_with_isolation() {
    local user_message="$1"
    
    echo "🚀 Starting module isolation workflow"
    echo "===================================="
    
    # Step 1: Module judgment
    echo "1. 🔍 Module judgment..."
    local detected_module=$(judge_module "$user_message")
    local current_module=$(get_current_module)
    
    echo "   Detected: $detected_module"
    echo "   Current: ${current_module:-None}"
    
    # Step 2: Handle module switch
    if [ -n "$current_module" ] && [ "$detected_module" != "$current_module" ]; then
        echo "2. 🔄 Module switch detected..."
        notify_module_switch "$current_module" "$detected_module"
        record_module_switch "$current_module" "$detected_module"
    elif [ -z "$current_module" ]; then
        echo "2. 🆕 New topic classification..."
        echo "   Classified as: $detected_module"
    else
        echo "2. 🔄 Module continuation..."
        echo "   Continuing in: $current_module"
    fi
    
    # Step 3: Set and load module
    echo "3. 📂 Setting module..."
    set_current_module "$detected_module"
    
    # Step 4: Generate response (placeholder)
    echo "4. 💬 Generating response..."
    echo "   Context: Module $detected_module"
    
    # Step 5: Archive
    echo "5. 📁 Ready for archiving..."
    echo "   Will archive to: memory/modules/$detected_module/mid_term/archive/"
    
    echo ""
    echo "✅ Workflow complete"
    echo "   Final module: $detected_module"
}

# Helper functions
get_current_module() {
    if [ -f "$CURRENT_MODULE_FILE" ]; then
        cat "$CURRENT_MODULE_FILE"
    fi
}

set_current_module() {
    local module="$1"
    echo "$module" > "$CURRENT_MODULE_FILE"
}

notify_module_switch() {
    local old_module="$1"
    local new_module="$2"
    
    echo "   ⚠️  Switching from $old_module to $new_module"
    echo "   Loading $new_module memory..."
}

record_module_switch() {
    local old_module="$1"
    local new_module="$2"
    
    echo "$(date -Iseconds): $old_module → $new_module" >> "$MODULE_SWITCH_HISTORY"
}

# Main execution
if [ $# -eq 1 ]; then
    process_with_isolation "$1"
else
    echo "Usage: $0 \"message\""
    echo ""
    echo "Examples:"
    echo "  $0 \"How to write a literature review?\""
    echo "  $0 \"工程月报应该包含哪些内容?\""
    echo "  $0 \"黄金价格趋势分析\""
    exit 1
fi