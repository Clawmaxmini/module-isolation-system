# Quick Reference Guide

## Core Principles

### Priority Order
```
Module Isolation > Memory Safety > Context Continuity > Response Speed
```

### Goal
**Work like a professional team - different tasks in different drawers**

## 5-Step Workflow

### 1. Judge Module
- Analyze message keywords
- Determine module归属
- Output: module name or "general_temporary"

### 2. Load Memory
- Check current module
- If switching: unload old, load new
- Update module state

### 3. Notify Switch (if needed)
- Only when明显domain jump
- Format: "Switching from [Old] to [New]"

### 4. Generate Response
- Use only current module memory
- Maintain专业context
- Explain boundaries if needed

### 5. Archive Content
- Save to correct module
- Update summaries
- Clean temp cache

## Default Modules

| Module | Keywords (EN/CN) | Purpose |
|--------|------------------|---------|
| **thesis_writing** | thesis, research, literature, academic / 论文, 研究, 文献, 学术 | Academic writing |
| **engineering_management** | engineering, project, construction, report / 工程, 项目, 施工, 月报 | Project management |
| **financial_analysis** | finance, trading, market, investment / 金融, 交易, 市场, 投资 | Market analysis |
| **tech_operations** | tech, code, deployment, docker / 技术, 部署, docker, api | Technical operations |
| **life_assistance** | travel, shopping, schedule, life / 旅行, 购物, 日程, 生活 | Daily life help |

## Key Scripts

### Initialization
```bash
./scripts/init_module_system.sh
```
- Creates module structure
- Sets up 5 default modules
- Creates example files

### Module Judgment
```bash
./scripts/judge_module.sh "Your message here"
```
- Returns module name
- Supports中文/English
- Keyword-based matching

### Workflow Enforcement
```bash
./scripts/workflow_enforcer.sh "Your message here"
```
- Full 5-step workflow
- Handles module switching
- Archives conversations

### Pollution Detection
```bash
./scripts/pollution_detector.sh
```
- Checks cross-module references
- Identifies contamination
- Generates report

### Health Reporting
```bash
./scripts/health_report.sh
```
- System status overview
- Usage statistics
- Maintenance recommendations

## Common Commands

### Quick Test
```bash
# Test module judgment
./scripts/judge_module.sh "文献综述怎么写？"
./scripts/judge_module.sh "工程进度报告"
./scripts/judge_module.sh "黄金价格分析"

# Test full workflow
./scripts/workflow_enforcer.sh "论文引言部分"
```

### System Maintenance
```bash
# Weekly check
./scripts/pollution_detector.sh
./scripts/health_report.sh

# Clean old files
find memory/modules/*/temp -type f -mtime +7 -delete

# Reset system (backup first!)
cp -r memory/modules memory/modules_backup_$(date +%Y%m%d)
rm -rf memory/modules
./scripts/init_module_system.sh
```

### Customization
```bash
# Add new module
mkdir -p memory/modules/new_module/{long_term,mid_term/archive,temp/sessions,config}

# Update keywords
vim scripts/judge_module.sh
# Add new condition to judge_module() function
```

## Integration Examples

### Python Integration
```python
import subprocess

def process_with_isolation(message):
    # Get module
    module = subprocess.run(
        ["./scripts/judge_module.sh", message],
        capture_output=True,
        text=True
    ).stdout.strip()
    
    # Your AI logic here
    response = your_ai_function(message, module)
    
    return response
```

### Shell Integration
```bash
#!/bin/bash
# ai_wrapper.sh

message="$1"
module=$(./scripts/judge_module.sh "$message")

echo "Processing in module: $module"
# Your AI call here
```

## Troubleshooting

### Problem: Wrong module detection
**Solution**: Update keywords in `judge_module.sh`

### Problem: Memory pollution
**Solution**: 
1. Run `./scripts/pollution_detector.sh`
2. Review report
3. Move contaminated files
4. Tighten boundaries

### Problem: Slow performance
**Solution**:
1. Clean temp files
2. Reduce module count if too many
3. Optimize file operations

### Problem: Need new module
**Solution**:
1. Create directory structure
2. Add config file
3. Update `judge_module.sh`
4. Test thoroughly

## Best Practices

### Do's
- ✅ Start with 2-3 core modules
- ✅ Define clear boundaries
- ✅ Run weekly maintenance
- ✅ Educate users about system
- ✅ Balance isolation and performance

### Don'ts
- ❌ Share memory between modules
- ❌ Skip module classification
- ❌ Allow contamination
- ❌ Create too many modules initially
- ❌ Neglect regular checks

## File Structure

```
module-isolation-system/
├── README.md              # Project overview
├── SKILL.md              # Main documentation
├── LICENSE               # MIT license
├── integration-guide.md  # Integration instructions
├── scripts/              # Core scripts
│   ├── judge_module.sh
│   ├── workflow_enforcer.sh
│   ├── pollution_detector.sh
│   ├── health_report.sh
│   └── init_module_system.sh
├── templates/            # Configuration templates
│   ├── module_config.json
│   └── role_mapping.json
├── examples/             # Usage examples
│   ├── example.txt
│   └── basic-usage.md
└── docs/                 # Additional documentation
    ├── module-isolation-rules.md
    └── quick-reference.md
```

## Memory Structure (per module)

```
memory/modules/module_name/
├── long_term/           # Permanent knowledge
├── mid_term/           # Current projects
│   └── archive/        # Archived sessions
├── temp/               # Session data
│   └── sessions/       # Current conversations
└── config/             # Module settings
    └── module_config.json
```

## Quick Start Checklist

1. [ ] `chmod +x scripts/*.sh`
2. [ ] `./scripts/init_module_system.sh`
3. [ ] `./scripts/judge_module.sh "Test message"`
4. [ ] `./scripts/workflow_enforcer.sh "Test message"`
5. [ ] `./scripts/health_report.sh`
6. [ ] Customize for your needs
7. [ ] Integrate with your AI assistant
8. [ ] Set up weekly maintenance

## Support

- **Issues**: GitHub repository issues
- **Documentation**: See SKILL.md and integration-guide.md
- **Examples**: Check examples/ directory
- **Community**: OpenClaw Discord, AI assistant forums

---

**Remember**: Quality collaboration requires clean separation. Keep your modules isolated like a professional team keeps their work organized.