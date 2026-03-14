#!/bin/bash
# Initialize module isolation system

MODULES_BASE="memory/modules"

# Initialize module memory structure
init_module_memory() {
    echo "🎯 Initializing module isolation system..."
    echo ""
    
    # Define modules
    local modules=("thesis_writing" "engineering_management" "financial_analysis" "tech_operations" "life_assistance")
    
    # Create base directory
    mkdir -p "$MODULES_BASE"
    
    # Initialize each module
    for module in "${modules[@]}"; do
        echo "Initializing module: $module"
        
        # Create directory structure
        mkdir -p "$MODULES_BASE/$module/long_term"
        mkdir -p "$MODULES_BASE/$module/mid_term/archive"
        mkdir -p "$MODULES_BASE/$module/temp/sessions"
        mkdir -p "$MODULES_BASE/$module/config"
        
        # Initialize config file
        cat > "$MODULES_BASE/$module/config/module_config.json" << EOF
{
  "module_name": "$module",
  "description": "$(get_module_description "$module")",
  "keywords": $(get_module_keywords "$module"),
  "created": "$(date -Iseconds)",
  "last_accessed": "$(date -Iseconds)",
  "access_count": 0,
  "memory_size": 0
}
EOF
        
        # Initialize summary file
        echo "# Module: $module" > "$MODULES_BASE/$module/mid_term/summary.md"
        echo "Created: $(date)" >> "$MODULES_BASE/$module/mid_term/summary.md"
        echo "Description: $(get_module_description "$module")" >> "$MODULES_BASE/$module/mid_term/summary.md"
        echo "" >> "$MODULES_BASE/$module/mid_term/summary.md"
        echo "## Keywords" >> "$MODULES_BASE/$module/mid_term/summary.md"
        get_module_keywords "$module" | tr ',' '\n' | sed 's/"/ /g' | while read -r keyword; do
            echo "- $keyword" >> "$MODULES_BASE/$module/mid_term/summary.md"
        done
        echo "" >> "$MODULES_BASE/$module/mid_term/summary.md"
        
        echo "  ✅ Created directory structure and config"
    done
    
    echo ""
    echo "✅ Module memory structure initialized"
    echo "   Total modules: ${#modules[@]}"
    echo "   Base path: $MODULES_BASE"
}

# Get module description
get_module_description() {
    local module="$1"
    
    case "$module" in
        "thesis_writing")
            echo "Academic writing and research"
            ;;
        "engineering_management")
            echo "Engineering project management"
            ;;
        "financial_analysis")
            echo "Financial market analysis"
            ;;
        "tech_operations")
            echo "Technical operations and DevOps"
            ;;
        "life_assistance")
            echo "Daily life assistance"
            ;;
        *)
            echo "General purpose module"
            ;;
    esac
}

# Get module keywords as JSON array
get_module_keywords() {
    local module="$1"
    
    case "$module" in
        "thesis_writing")
            echo '["thesis", "research", "literature", "citation", "academic", "paper", "writing", "文献", "论文", "学术"]'
            ;;
        "engineering_management")
            echo '["engineering", "project", "report", "inspection", "construction", "management", "progress", "工程", "项目", "施工", "月报"]'
            ;;
        "financial_analysis")
            echo '["finance", "trading", "market", "investment", "analysis", "stock", "currency", "gold", "金融", "交易", "市场", "投资", "黄金"]'
            ;;
        "tech_operations")
            echo '["technology", "code", "programming", "deployment", "server", "api", "docker", "container", "技术", "部署", "docker", "api"]'
            ;;
        "life_assistance")
            echo '["travel", "shopping", "schedule", "planning", "decision", "daily", "life", "旅行", "购物", "日程", "生活"]'
            ;;
        *)
            echo '["general", "temporary", "misc"]'
            ;;
    esac
}

# Create example files
create_example_files() {
    echo ""
    echo "📝 Creating example files..."
    
    # Example for thesis_writing
    cat > "$MODULES_BASE/thesis_writing/long_term/writing_tips.md" << EOF
# Thesis Writing Tips

## Literature Review
1. Start with a broad search
2. Use academic databases
3. Organize by theme
4. Identify gaps in research

## Structure
- Introduction
- Literature Review
- Methodology
- Results
- Discussion
- Conclusion

## Common Mistakes
- Poor citation management
- Weak thesis statement
- Inadequate literature review
- Unclear methodology
EOF
    
    # Example for engineering_management
    cat > "$MODULES_BASE/engineering_management/long_term/project_templates.md" << EOF
# Engineering Project Templates

## Progress Report Template
### Project: [Project Name]
### Period: [Date Range]

1. **Progress Summary**
   - Completed tasks
   - In-progress tasks
   - Upcoming tasks

2. **Issues and Risks**
   - Current issues
   - Risk assessment
   - Mitigation plans

3. **Next Steps**
   - Immediate actions
   - Long-term plans
   - Resource requirements
EOF
    
    # Example for financial_analysis
    cat > "$MODULES_BASE/financial_analysis/long_term/analysis_framework.md" << EOF
# Financial Analysis Framework

## Market Analysis
1. **Macro Factors**
   - Economic indicators
   - Interest rates
   - Inflation

2. **Sector Analysis**
   - Industry trends
   - Competitive landscape
   - Regulatory environment

3. **Company Analysis**
   - Financial statements
   - Management quality
   - Growth prospects
EOF
    
    echo "  ✅ Created example files in each module"
}

# Set up scripts
setup_scripts() {
    echo ""
    echo "🔧 Setting up scripts..."
    
    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null
    
    # Create a simple test script
    cat > "test_module_system.sh" << 'EOF'
#!/bin/bash
echo "🧪 Testing module isolation system..."
echo ""

# Test module judgment
echo "1. Testing module judgment:"
echo "   'How to write a literature review?' -> $(./scripts/judge_module.sh "How to write a literature review?")"
echo "   '工程月报应该包含哪些内容?' -> $(./scripts/judge_module.sh "工程月报应该包含哪些内容")"
echo "   '黄金价格趋势分析' -> $(./scripts/judge_module.sh "黄金价格趋势分析")"
echo ""

# Test workflow
echo "2. Testing workflow enforcement:"
./scripts/workflow_enforcer.sh "How to structure a research paper?" > /dev/null
echo "   ✅ Workflow test completed"
echo ""

# Check directory structure
echo "3. Checking directory structure:"
if [ -d "memory/modules" ]; then
    echo "   ✅ Modules directory exists"
    module_count=$(ls -d memory/modules/*/ 2>/dev/null | wc -l)
    echo "   ✅ Found $module_count modules"
else
    echo "   ❌ Modules directory not found"
fi
echo ""

echo "🎉 Module isolation system is ready!"
EOF
    
    chmod +x test_module_system.sh
    
    echo "  ✅ Created test script: test_module_system.sh"
}

# Display usage instructions
display_usage() {
    echo ""
    echo "📚 Usage Instructions:"
    echo "====================="
    echo ""
    echo "1. **Initialize system**:"
    echo "   ./scripts/init_module_system.sh"
    echo ""
    echo "2. **Test module judgment**:"
    echo "   ./scripts/judge_module.sh \"Your message here\""
    echo ""
    echo "3. **Use workflow enforcement**:"
    echo "   ./scripts/workflow_enforcer.sh \"Your message here\""
    echo ""
    echo "4. **Check for pollution**:"
    echo "   ./scripts/pollution_detector.sh"
    echo ""
    echo "5. **Generate health report**:"
    echo "   ./scripts/health_report.sh"
    echo ""
    echo "6. **Run system test**:"
    echo "   ./test_module_system.sh"
    echo ""
    echo "💡 Tip: Review the SKILL.md file for detailed documentation"
}

# Main execution
main() {
    echo "========================================="
    echo "   Module Isolation System Initializer   "
    echo "========================================="
    echo ""
    
    # Initialize memory structure
    init_module_memory
    
    # Create example files
    create_example_files
    
    # Setup scripts
    setup_scripts
    
    # Display usage
    display_usage
    
    echo ""
    echo "✅ Initialization complete!"
    echo "   Your module isolation system is ready to use."
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Review the created structure"
    echo "   2. Test with the provided scripts"
    echo "   3. Customize modules for your needs"
    echo "   4. Integrate with your AI assistant"
}

# Run main function
main