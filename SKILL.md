---
name: module-isolation-system
description: Strict module isolation system for long-term collaborative AI assistants. Prevents context pollution between different topics/modules, enforces clean separation of memory, and enables professional team-like collaboration.
---

# Module Isolation System

A professional-grade module isolation framework for long-term collaborative AI assistants. This skill provides strict rules, workflows, and tools to prevent context pollution between different specialized domains.

## Core Principle

**Module Isolation > Memory Safety > Context Continuity > Response Speed**

## When to Use This Skill

Use this skill when:

1. **Building long-term collaborative AI assistants** that handle multiple specialized domains
2. **Managing multi-role AI systems** where each role has distinct expertise
3. **Preventing context pollution** between unrelated topics
4. **Implementing professional team-like workflows**
5. **Ensuring memory safety** by strictly separating different domain memories

## Quick Start

### Basic Workflow

Every interaction must follow this 5-step sequence:

1. **Module Judgment** - Determine which module the message belongs to
2. **Memory Loading** - Load the corresponding module's memory
3. **Switch Notification** - Notify if module switching is needed
4. **Response Generation** - Answer within the module's context only
5. **Content Archiving** - Archive to the correct module's memory

### Key Prompt Templates

#### Module Switch Notification:
```
"Detected topic switch from [Old Module] to [New Module].
I will pause the old module context and continue after loading the new module's memory."
```

#### New Topic Classification:
```
"I will first classify this topic. Current classification: [Module Name].
I will continue the discussion based on this module's memory."
```

#### Multi-Module Message:
```
"This message involves multiple modules. To avoid memory pollution,
I will process it primarily in [Main Module], with other parts as auxiliary calls."
```

## Core Rules

### Absolute Prohibitions

1. **❌ NO shared memory between modules** - Each module maintains independent memory
2. **❌ NO unclassified new topics** - Always classify before responding
3. **❌ NO memory contamination after switching** - Old module memory must be unloaded
4. **❌ NO mixing that becomes indistinguishable** - Conversations must remain clearly separated

### Memory Structure (Per Module)

Each module maintains three levels of memory:

- **Long-term Memory**: Module definitions, user preferences, specialized templates
- **Mid-term Memory**: Current active topics, historical summaries, stage tasks
- **Temporary Memory**: Current session content, temporary files/cache

**All memories must be attached to their respective modules and must not be misplaced.**

## Implementation Guide

### Step 1: Module Definition

Define your modules based on actual needs. Example module structure:

```json
{
  "modules": {
    "thesis_writing": {
      "name": "Academic Thesis Writing",
      "keywords": ["thesis", "literature", "research", "citation", "academic"],
      "memory_path": "memory/modules/thesis/"
    },
    "engineering_management": {
      "name": "Engineering Project Management", 
      "keywords": ["engineering", "project", "report", "inspection", "construction"],
      "memory_path": "memory/modules/engineering/"
    },
    "financial_analysis": {
      "name": "Financial Market Analysis",
      "keywords": ["finance", "trading", "market", "analysis", "investment"],
      "memory_path": "memory/modules/finance/"
    }
  }
}
```

### Step 2: Module Judgment System

Implement keyword-based module detection:

```bash
#!/bin/bash
# judge_module.sh

judge_module() {
  local message="$1"
  local lower_message=$(echo "$message" | tr '[:upper:]' '[:lower:]')
  
  if [[ "$lower_message" =~ (thesis|research|literature|citation|academic) ]]; then
    echo "thesis_writing"
  elif [[ "$lower_message" =~ (engineering|project|report|inspection|construction) ]]; then
    echo "engineering_management"
  elif [[ "$lower_message" =~ (finance|trading|market|investment|analysis) ]]; then
    echo "financial_analysis"
  elif [[ "$lower_message" =~ (tech|code|deployment|docker|api) ]]; then
    echo "tech_operations"
  elif [[ "$lower_message" =~ (travel|shopping|schedule|planning|life) ]]; then
    echo "life_assistance"
  else
    echo "general_temporary"
  fi
}

# Usage
module=$(judge_module "How to write a literature review?")
echo "Detected module: $module"
```

### Step 3: Memory Management

Create isolated memory directories:

```bash
#!/bin/bash
# init_module_system.sh

MODULES_BASE="memory/modules"

init_module_memory() {
  local modules=("thesis_writing" "engineering_management" "financial_analysis" "tech_operations" "life_assistance")
  
  for module in "${modules[@]}"; do
    mkdir -p "$MODULES_BASE/$module/long_term"
    mkdir -p "$MODULES_BASE/$module/mid_term/archive"
    mkdir -p "$MODULES_BASE/$module/temp/sessions"
    mkdir -p "$MODULES_BASE/$module/config"
    
    cat > "$MODULES_BASE/$module/config/module_config.json" << EOF
{
  "module_name": "$module",
  "created": "$(date -Iseconds)",
  "last_accessed": "$(date -Iseconds)",
  "access_count": 0
}
EOF
  done
  
  echo "✅ Module memory structure initialized"
}

init_module_memory
```

### Step 4: Workflow Enforcement

Enforce the 5-step workflow:

```bash
#!/bin/bash
# workflow_enforcer.sh

CURRENT_MODULE_FILE=".current_module"

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
    echo "   ⚠️  Switching from $current_module to $detected_module"
    echo "   Loading $detected_module memory..."
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
  
  # Step 4: Generate response
  echo "4. 💬 Generating response..."
  echo "   Context: Module $detected_module"
  
  # Step 5: Archive
  echo "5. 📁 Ready for archiving..."
  echo "   Will archive to: memory/modules/$detected_module/mid_term/archive/"
  
  echo ""
  echo "✅ Workflow complete"
  echo "   Final module: $detected_module"
}

get_current_module() {
  if [ -f "$CURRENT_MODULE_FILE" ]; then
    cat "$CURRENT_MODULE_FILE"
  fi
}

set_current_module() {
  local module="$1"
  echo "$module" > "$CURRENT_MODULE_FILE"
}

# Include judge_module function
source scripts/judge_module.sh

# Main execution
if [ $# -eq 1 ]; then
  process_with_isolation "$1"
else
  echo "Usage: $0 \"message\""
  exit 1
fi
```

## Advanced Features

### Pollution Detection

```bash
#!/bin/bash
# pollution_detector.sh

MODULES_BASE="memory/modules"

check_cross_module_references() {
  echo "🔍 Checking for cross-module references..."
  
  declare -A problematic_patterns=(
    ["thesis_writing"]="engineering|finance|tech"
    ["engineering_management"]="thesis|finance|life"
    ["financial_analysis"]="thesis|engineering|life"
    ["tech_operations"]="thesis|finance|life"
    ["life_assistance"]="thesis|engineering|finance|tech"
  )
  
  for module_dir in "$MODULES_BASE"/*/; do
    local module=$(basename "$module_dir")
    local patterns=${problematic_patterns[$module]}
    
    if [ -n "$patterns" ]; then
      local matches=$(grep -r -i -E "$patterns" "$module_dir" 2>/dev/null | wc -l)
      
      if [ "$matches" -gt 0 ]; then
        echo "❌ Found $matches potential pollution cases in $module"
      else
        echo "✅ $module: No pollution detected"
      fi
    fi
  done
}

check_cross_module_references
```

### Module Health Reports

```bash
#!/bin/bash
# health_report.sh

MODULES_BASE="memory/modules"

generate_health_report() {
  echo "📊 Module System Health Report"
  echo "============================="
  echo ""
  
  for module_dir in "$MODULES_BASE"/*/; do
    local module=$(basename "$module_dir")
    local file_count=$(find "$module_dir" -type f | wc -l)
    local size_kb=$(du -sk "$module_dir" 2>/dev/null | cut -f1)
    
    echo "Module: $module"
    echo "  Files: $file_count"
    echo "  Size: ${size_kb:-0} KB"
    
    # Check config file
    local config_file="$module_dir/config/module_config.json"
    if [ -f "$config_file" ]; then
      local access_count=$(jq -r '.access_count' "$config_file" 2>/dev/null || echo "0")
      local last_accessed=$(jq -r '.last_accessed' "$config_file" 2>/dev/null || echo "Unknown")
      echo "  Access count: $access_count"
      echo "  Last accessed: $last_accessed"
    fi
    
    echo ""
  done
  
  echo "📊 Health report generated at: $(date)"
}

generate_health_report
```

## Integration Examples

### Integration with OpenClaw

See [integration-guide.md](integration-guide.md) for detailed integration instructions.

### Integration with Python

```python
# module_isolation.py
class ModuleIsolationWrapper:
    def __init__(self, assistant, config):
        self.assistant = assistant
        self.config = config
        self.current_module = None
    
    def process_with_isolation(self, message):
        # 1. Module judgment
        module = self.judge_module(message)
        
        # 2. Handle module switch
        if self.current_module and module != self.current_module:
            print(f"🔄 Switching from {self.current_module} to {module}")
        
        # 3. Update current module
        self.current_module = module
        
        # 4. Load module context
        context = self.load_module_context(module)
        
        # 5. Generate response
        response = self.generate_response(message, context)
        
        # 6. Archive
        self.archive_conversation(module, message, response)
        
        return response
    
    def judge_module(self, message):
        # Implementation depends on your needs
        message_lower = message.lower()
        if any(word in message_lower for word in ["thesis", "research", "academic"]):
            return "thesis_writing"
        elif any(word in message_lower for word in ["engineering", "project", "construction"]):
            return "engineering_management"
        else:
            return "general_temporary"
```

## Best Practices

### 1. Start Simple
Begin with 2-3 core modules, expand as needed.

### 2. Clear Boundaries
Define clear, non-overlapping module boundaries.

### 3. Regular Audits
Run pollution checks weekly to catch contamination early.

### 4. User Education
Educate users about the module system.

### 5. Performance Balance
Optimize memory loading while maintaining isolation.

## Troubleshooting

### Problem: Module judgment is inaccurate
**Solution**: Refine keyword lists, add context-aware judgment.

### Problem: Memory loading is slow
**Solution**: Implement lazy loading, cache frequently used modules.

### Problem: Users complain about context switching
**Solution**: Improve switch notifications, provide quick module overview.

### Problem: Memory pollution detected
**Solution**: Run cleanup scripts, review recent conversations.

## References

For detailed integration guides and examples, see:
- [integration-guide.md](integration-guide.md)
- [examples/](examples/)
- [docs/](docs/)

## License & Sharing

This module isolation system is designed to be shared across AI assistant platforms. The core principles are universal and can be adapted to any multi-domain AI system.

**Share on GitHub**: Package includes all necessary files for easy sharing and collaboration.

---

**Remember**: The goal is not just to chat, but to work like a professional team—putting different tasks in different drawers to avoid contamination.