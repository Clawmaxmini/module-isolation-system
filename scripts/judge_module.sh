#!/bin/bash
# Module judgment based on keywords

judge_module() {
    local message="$1"
    
    # Convert to lowercase for case-insensitive matching
    local lower_message=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Module keyword definitions
    local thesis_keywords="thesis|research|literature|citation|academic|paper|writing|文献|论文|学术"
    local engineering_keywords="engineering|project|report|inspection|construction|management|progress|工程|项目|施工|月报"
    local finance_keywords="finance|trading|market|investment|analysis|stock|currency|gold|金融|交易|市场|投资|黄金"
    local tech_keywords="technology|code|programming|deployment|server|api|docker|container|技术|部署|docker|api"
    local life_keywords="travel|shopping|schedule|planning|decision|daily|life|旅行|购物|日程|生活"
    
    # Priority-based matching
    if [[ "$lower_message" =~ ($thesis_keywords) ]]; then
        echo "thesis_writing"
    elif [[ "$lower_message" =~ ($engineering_keywords) ]]; then
        echo "engineering_management"
    elif [[ "$lower_message" =~ ($finance_keywords) ]]; then
        echo "financial_analysis"
    elif [[ "$lower_message" =~ ($tech_keywords) ]]; then
        echo "tech_operations"
    elif [[ "$lower_message" =~ ($life_keywords) ]]; then
        echo "life_assistance"
    else
        echo "general_temporary"
    fi
}

# If called directly, test the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -eq 1 ]; then
        module=$(judge_module "$1")
        echo "Detected module: $module"
    else
        echo "Usage: $0 \"message\""
        echo "Example: $0 \"How to write a literature review?\""
        exit 1
    fi
fi