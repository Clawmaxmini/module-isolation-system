# Basic Usage Guide

This guide provides step-by-step instructions for using the Module Isolation System.

## Quick Start

### Step 1: Initialize the System

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Initialize module system
./scripts/init_module_system.sh
```

This will create:
- `memory/modules/` directory structure
- 5 default modules with config files
- Example files in each module
- Test script

### Step 2: Test Module Judgment

```bash
# Test with different types of messages
./scripts/judge_module.sh "How to write a research paper?"
# Output: thesis_writing

./scripts/judge_module.sh "工程月报格式"
# Output: engineering_management

./scripts/judge_module.sh "股票市场分析"
# Output: financial_analysis
```

### Step 3: Use Workflow Enforcement

```bash
# Process a message with full isolation workflow
./scripts/workflow_enforcer.sh "文献综述怎么写？"
```

### Step 4: Check System Health

```bash
# Generate health report
./scripts/health_report.sh

# Check for memory pollution
./scripts/pollution_detector.sh
```

## Default Modules

The system comes with 5 pre-configured modules:

### 1. thesis_writing (学术论文)
- **Keywords**: thesis, research, literature, citation, academic, paper, writing, 文献, 论文, 学术
- **Purpose**: Academic writing and research assistance
- **Example topics**: Literature reviews, methodology, citations, paper structure

### 2. engineering_management (工程管理)
- **Keywords**: engineering, project, report, inspection, construction, management, progress, 工程, 项目, 施工, 月报
- **Purpose**: Engineering project management
- **Example topics**: Progress reports, project plans, inspections, construction management

### 3. financial_analysis (金融分析)
- **Keywords**: finance, trading, market, investment, analysis, stock, currency, gold, 金融, 交易, 市场, 投资, 黄金
- **Purpose**: Financial market analysis
- **Example topics**: Market trends, investment analysis, stock research, economic indicators

### 4. tech_operations (技术运维)
- **Keywords**: technology, code, programming, deployment, server, api, docker, container, 技术, 部署, docker, api
- **Purpose**: Technical operations and DevOps
- **Example topics**: Docker configuration, API development, server management, coding

### 5. life_assistance (生活事务)
- **Keywords**: travel, shopping, schedule, planning, decision, daily, life, 旅行, 购物, 日程, 生活
- **Purpose**: Daily life assistance
- **Example topics**: Travel planning, shopping advice, schedule management, daily decisions

## Core Concepts

### Module Isolation Priority
The system follows this priority order:
1. **Module Isolation** - Keep domains separate
2. **Memory Safety** - Prevent data loss
3. **Context Continuity** - Maintain conversation flow
4. **Response Speed** - Optimize performance

### 5-Step Workflow
Every message goes through:
1. **Judge** - Determine module
2. **Load** - Load module memory
3. **Notify** - Announce switches
4. **Respond** - Generate answer
5. **Archive** - Save to module

### Memory Structure
Each module has:
- **long_term/** - Permanent knowledge
- **mid_term/** - Current projects
- **temp/** - Session data
- **config/** - Module settings

## Common Tasks

### Adding a New Module

1. Create module directory:
```bash
mkdir -p memory/modules/new_module/{long_term,mid_term/archive,temp/sessions,config}
```

2. Create config file:
```bash
cat > memory/modules/new_module/config/module_config.json << EOF
{
  "module_name": "new_module",
  "description": "Description of your new module",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "created": "$(date -Iseconds)",
  "last_accessed": "$(date -Iseconds)",
  "access_count": 0
}
EOF
```

3. Update `scripts/judge_module.sh`:
Add a new condition to the `judge_module()` function.

### Customizing Keywords

Edit `scripts/judge_module.sh` to modify keyword matching:

```bash
# Example: Add more keywords to thesis_writing
local thesis_keywords="thesis|research|literature|citation|academic|paper|writing|文献|论文|学术|研究|学术论文"
```

### Integrating with AI Assistant

#### Python Integration:
```python
import subprocess

class IsolatedAssistant:
    def __init__(self):
        self.current_module = None
    
    def process(self, message):
        # Get module
        module = subprocess.run(
            ["./scripts/judge_module.sh", message],
            capture_output=True,
            text=True
        ).stdout.strip()
        
        # Handle module switch
        if self.current_module and module != self.current_module:
            print(f"Switching from {self.current_module} to {module}")
        
        self.current_module = module
        
        # Your AI logic here, using module context
        response = self.generate_response(message, module)
        
        return response
```

#### Shell Integration:
```bash
#!/bin/bash
# ai_wrapper.sh

process_message() {
    local message="$1"
    
    # Get module
    local module=$(./scripts/judge_module.sh "$message")
    
    # Load module context
    local context_file="memory/modules/$module/mid_term/current_context.md"
    local context=""
    
    if [ -f "$context_file" ]; then
        context=$(cat "$context_file")
    fi
    
    # Generate response (replace with your AI call)
    echo "Response from $module module: $message"
    
    # Archive
    echo "$(date): $message" >> "memory/modules/$module/mid_term/archive/conversations.md"
}

# Usage
process_message "How to write an abstract?"
```

## Maintenance

### Weekly Tasks
1. Run pollution check: `./scripts/pollution_detector.sh`
2. Generate health report: `./scripts/health_report.sh`
3. Clean old temp files: `find memory/modules/*/temp -type f -mtime +7 -delete`

### Monthly Tasks
1. Archive old sessions
2. Review module boundaries
3. Update keywords if needed

### As Needed
1. Add new modules
2. Customize for specific domains
3. Integrate with other systems

## Troubleshooting

### Problem: Module not detected correctly
**Solution**: Update keywords in `judge_module.sh`

### Problem: Memory pollution detected
**Solution**: 
1. Review pollution report
2. Move contaminated files
3. Tighten module boundaries

### Problem: System running slow
**Solution**:
1. Clean temp files
2. Reduce module count if too many
3. Optimize file I/O

### Problem: Need to reset system
**Solution**:
```bash
# Backup if needed
cp -r memory/modules memory/modules_backup_$(date +%Y%m%d)

# Reinitialize
rm -rf memory/modules
./scripts/init_module_system.sh
```

## Best Practices

1. **Start Simple**: Begin with 2-3 core modules
2. **Clear Boundaries**: Avoid overlapping keywords
3. **Regular Maintenance**: Weekly checks prevent issues
4. **User Education**: Explain the module system to users
5. **Performance Balance**: Optimize without sacrificing isolation

## Next Steps

After mastering basic usage:

1. **Advanced Integration**: Connect with your AI assistant
2. **Custom Modules**: Add domains specific to your needs
3. **Automation**: Set up scheduled maintenance
4. **Monitoring**: Implement usage analytics
5. **Sharing**: Package and share your module configurations

Remember: The goal is professional collaboration, not just conversation. Keep domains separate to maintain quality and prevent contamination.