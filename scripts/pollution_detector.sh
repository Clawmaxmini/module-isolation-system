#!/bin/bash
# Detect memory pollution between modules

MODULES_BASE="memory/modules"

# Check for cross-module references
check_cross_module_references() {
    echo "🔍 Checking for cross-module references..."
    echo ""
    
    local pollution_found=0
    local report_file="/tmp/pollution_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Define problematic patterns
    declare -A problematic_patterns=(
        ["thesis_writing"]="engineering|finance|tech|工程|金融|技术"
        ["engineering_management"]="thesis|finance|life|论文|金融|生活"
        ["financial_analysis"]="thesis|engineering|life|论文|工程|生活"
        ["tech_operations"]="thesis|finance|life|论文|金融|生活"
        ["life_assistance"]="thesis|engineering|finance|tech|论文|工程|金融|技术"
    )
    
    for module_dir in "$MODULES_BASE"/*/; do
        local module=$(basename "$module_dir")
        local patterns=${problematic_patterns[$module]}
        
        if [ -n "$patterns" ]; then
            echo "Checking $module for patterns: $patterns"
            
            local matches=$(grep -r -i -E "$patterns" "$module_dir" 2>/dev/null | wc -l)
            
            if [ "$matches" -gt 0 ]; then
                pollution_found=1
                echo "❌ Found $matches potential pollution cases in $module" | tee -a "$report_file"
                
                # Show top 3 examples
                echo "   Examples:" | tee -a "$report_file"
                grep -r -i -E "$patterns" "$module_dir" 2>/dev/null | head -3 | while read -r line; do
                    echo "   - $line" | tee -a "$report_file"
                done
                echo "" | tee -a "$report_file"
            else
                echo "✅ $module: No pollution detected"
            fi
        fi
    done
    
    if [ "$pollution_found" -eq 1 ]; then
        echo ""
        echo "🚨 Pollution detected! Report saved to: $report_file"
        echo "💡 Recommended actions:"
        echo "   1. Review the pollution cases"
        echo "   2. Clean contaminated files"
        echo "   3. Tighten module boundaries"
        echo "   4. Run cleanup scripts"
        return 1
    else
        echo ""
        echo "✅ No memory pollution detected"
        rm -f "$report_file" 2>/dev/null
        return 0
    fi
}

# Check for mixed content files
check_mixed_content() {
    echo "🔍 Checking for mixed content files..."
    echo ""
    
    local mixed_files=0
    
    for module_dir in "$MODULES_BASE"/*/; do
        local module=$(basename "$module_dir")
        
        # Check for files that might belong to other modules
        for file in "$module_dir"/*.md "$module_dir"/**/*.md 2>/dev/null; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                
                # Skip if it's a config or summary file
                if [[ "$filename" == *config* ]] || [[ "$filename" == *summary* ]]; then
                    continue
                fi
                
                # Check first few lines for module mentions
                local first_lines=$(head -10 "$file" 2>/dev/null)
                
                # Look for mentions of other modules
                for other_module in thesis_writing engineering_management financial_analysis tech_operations life_assistance; do
                    if [ "$other_module" != "$module" ] && [[ "$first_lines" =~ $other_module ]]; then
                        echo "⚠️  File $filename in $module mentions $other_module"
                        mixed_files=$((mixed_files + 1))
                        break
                    fi
                done
            fi
        done
    done
    
    if [ "$mixed_files" -gt 0 ]; then
        echo ""
        echo "⚠️  Found $mixed_files potentially mixed content files"
        echo "   Consider reviewing these files for proper module assignment"
        return 1
    else
        echo "✅ No mixed content files detected"
        return 0
    fi
}

# Check module directory structure
check_directory_structure() {
    echo "🔍 Checking module directory structure..."
    echo ""
    
    local structure_issues=0
    
    for module_dir in "$MODULES_BASE"/*/; do
        local module=$(basename "$module_dir")
        
        # Check required directories
        local required_dirs=("long_term" "mid_term" "temp" "config")
        
        for dir in "${required_dirs[@]}"; do
            if [ ! -d "$module_dir/$dir" ]; then
                echo "❌ $module: Missing directory: $dir"
                structure_issues=$((structure_issues + 1))
            fi
        done
        
        # Check config file
        if [ ! -f "$module_dir/config/module_config.json" ]; then
            echo "❌ $module: Missing config file: module_config.json"
            structure_issues=$((structure_issues + 1))
        fi
    done
    
    if [ "$structure_issues" -eq 0 ]; then
        echo "✅ All modules have correct directory structure"
        return 0
    else
        echo ""
        echo "⚠️  Found $structure_issues directory structure issues"
        return 1
    fi
}

# Main execution
main() {
    echo "🧹 Module Pollution Detection System"
    echo "==================================="
    echo ""
    
    # Check if modules directory exists
    if [ ! -d "$MODULES_BASE" ]; then
        echo "❌ Modules directory not found: $MODULES_BASE"
        echo "   Run init_module_system.sh first"
        exit 1
    fi
    
    local total_issues=0
    
    # Run all checks
    check_directory_structure || total_issues=$((total_issues + 1))
    echo ""
    
    check_cross_module_references || total_issues=$((total_issues + 1))
    echo ""
    
    check_mixed_content || total_issues=$((total_issues + 1))
    echo ""
    
    # Summary
    echo "📊 Summary"
    echo "=========="
    
    if [ "$total_issues" -eq 0 ]; then
        echo "✅ All checks passed! Module system is clean."
        exit 0
    else
        echo "⚠️  Found $total_issues types of issues"
        echo ""
        echo "💡 Recommendations:"
        echo "   1. Run cleanup scripts"
        echo "   2. Review pollution reports"
        echo "   3. Consider tightening module boundaries"
        echo "   4. Regular maintenance is key to preventing pollution"
        exit 1
    fi
}

# Run main function
main