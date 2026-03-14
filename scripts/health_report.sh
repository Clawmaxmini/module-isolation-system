#!/bin/bash
# Generate module system health report

MODULES_BASE="memory/modules"
REPORT_FILE="module_health_report_$(date +%Y%m%d_%H%M%S).md"

# Generate health report
generate_health_report() {
    echo "# 📊 Module System Health Report" > "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Generated**: $(date)" >> "$REPORT_FILE"
    echo "**Report File**: $REPORT_FILE" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "## Module Overview" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    local total_files=0
    local total_size_kb=0
    local module_count=0
    
    for module_dir in "$MODULES_BASE"/*/; do
        local module=$(basename "$module_dir")
        module_count=$((module_count + 1))
        
        # Count files
        local file_count=$(find "$module_dir" -type f | wc -l)
        total_files=$((total_files + file_count))
        
        # Calculate size
        local size_kb=$(du -sk "$module_dir" 2>/dev/null | cut -f1)
        total_size_kb=$((total_size_kb + size_kb))
        
        # Get access info
        local access_count="N/A"
        local last_accessed="N/A"
        local config_file="$module_dir/config/module_config.json"
        
        if [ -f "$config_file" ]; then
            access_count=$(jq -r '.access_count' "$config_file" 2>/dev/null || echo "N/A")
            last_accessed=$(jq -r '.last_accessed' "$config_file" 2>/dev/null || echo "N/A")
        fi
        
        # Write module info
        echo "### $module" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "- **Files**: $file_count" >> "$REPORT_FILE"
        echo "- **Size**: ${size_kb:-0} KB" >> "$REPORT_FILE"
        echo "- **Access Count**: $access_count" >> "$REPORT_FILE"
        echo "- **Last Accessed**: $last_accessed" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # Check directory structure
        echo "  **Directory Check**: " >> "$REPORT_FILE"
        local missing_dirs=0
        for dir in "long_term" "mid_term" "temp" "config"; do
            if [ -d "$module_dir/$dir" ]; then
                echo "    ✅ $dir" >> "$REPORT_FILE"
            else
                echo "    ❌ $dir (missing)" >> "$REPORT_FILE"
                missing_dirs=$((missing_dirs + 1))
            fi
        done
        echo "" >> "$REPORT_FILE"
    done
    
    echo "## System Summary" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "- **Total Modules**: $module_count" >> "$REPORT_FILE"
    echo "- **Total Files**: $total_files" >> "$REPORT_FILE"
    echo "- **Total Size**: $total_size_kb KB ($((total_size_kb / 1024)) MB)" >> "$REPORT_FILE"
    echo "- **Report Time**: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Run pollution check
    echo "## Pollution Status" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    local pollution_output=$(./pollution_detector.sh 2>&1 | tail -20)
    if echo "$pollution_output" | grep -q "No memory pollution detected"; then
        echo "✅ **No pollution detected**" >> "$REPORT_FILE"
    else
        echo "⚠️ **Pollution detected**" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "```" >> "$REPORT_FILE"
        echo "$pollution_output" >> "$REPORT_FILE"
        echo "```" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
    # Recommendations
    echo "## Recommendations" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for old temp files
    local old_temp_files=$(find "$MODULES_BASE" -name "*.tmp" -o -name "temp/*" -mtime +7 2>/dev/null | wc -l)
    if [ "$old_temp_files" -gt 0 ]; then
        echo "⚠️ **Cleanup needed**: $old_temp_files temp files older than 7 days" >> "$REPORT_FILE"
    else
        echo "✅ **Temp files**: Up to date" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
    # Module usage analysis
    echo "### Module Usage Analysis" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Find most and least used modules
    local most_used_module=""
    local most_used_count=0
    local least_used_module=""
    local least_used_count=999999
    
    for module_dir in "$MODULES_BASE"/*/; do
        local module=$(basename "$module_dir")
        local config_file="$module_dir/config/module_config.json"
        
        if [ -f "$config_file" ]; then
            local count=$(jq -r '.access_count' "$config_file" 2>/dev/null)
            if [[ "$count" =~ ^[0-9]+$ ]]; then
                if [ "$count" -gt "$most_used_count" ]; then
                    most_used_count=$count
                    most_used_module=$module
                fi
                if [ "$count" -lt "$least_used_count" ]; then
                    least_used_count=$count
                    least_used_module=$module
                fi
            fi
        fi
    done
    
    if [ -n "$most_used_module" ]; then
        echo "- **Most Used**: $most_used_module ($most_used_count accesses)" >> "$REPORT_FILE"
        echo "- **Least Used**: $least_used_module ($least_used_count accesses)" >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
    echo "### Maintenance Tasks" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "1. **Weekly**: Run pollution detection" >> "$REPORT_FILE"
    echo "2. **Monthly**: Archive old sessions" >> "$REPORT_FILE"
    echo "3. **Quarterly**: Review module boundaries" >> "$REPORT_FILE"
    echo "4. **As needed**: Update module keywords" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "---" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "*Report generated by Module Isolation System Health Check*" >> "$REPORT_FILE"
}

# Display report summary
display_summary() {
    echo "🧪 Generating health report..."
    echo ""
    
    generate_health_report
    
    echo "✅ Health report generated: $REPORT_FILE"
    echo ""
    echo "📋 Report Summary:"
    echo "-----------------"
    
    # Display key metrics
    local module_count=$(ls -d "$MODULES_BASE"/*/ 2>/dev/null | wc -l)
    local total_files=$(find "$MODULES_BASE" -type f 2>/dev/null | wc -l)
    local total_size_kb=$(du -sk "$MODULES_BASE" 2>/dev/null | cut -f1)
    
    echo "• Modules: $module_count"
    echo "• Total Files: $total_files"
    echo "• Total Size: ${total_size_kb:-0} KB"
    echo ""
    
    # Check pollution status
    echo "🔍 Running pollution check..."
    ./pollution_detector.sh > /tmp/pollution_check.txt 2>&1
    
    if grep -q "No memory pollution detected" /tmp/pollution_check.txt; then
        echo "✅ Pollution: None detected"
    else
        echo "⚠️ Pollution: Issues found (see report)"
    fi
    
    echo ""
    echo "📊 Full report available in: $REPORT_FILE"
    echo "💡 Review recommendations for system maintenance"
}

# Main execution
main() {
    # Check if modules directory exists
    if [ ! -d "$MODULES_BASE" ]; then
        echo "❌ Modules directory not found: $MODULES_BASE"
        echo "   Run init_module_system.sh first"
        exit 1
    fi
    
    display_summary
}

# Run main function
main