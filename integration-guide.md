# Integration Guide

This guide provides detailed instructions for integrating the Module Isolation System with various AI assistant platforms.

## Table of Contents

1. [Integration with OpenClaw](#integration-with-openclaw)
2. [Integration with Python AI Assistants](#integration-with-python-ai-assistants)
3. [Integration with LangChain](#integration-with-langchain)
4. [Integration with Existing Role Systems](#integration-with-existing-role-systems)
5. [Custom Module Configuration](#custom-module-configuration)
6. [Troubleshooting](#troubleshooting)

## Integration with OpenClaw

### Basic Integration

#### Step 1: Install the Skill
```bash
# Clone or copy the skill to OpenClaw skills directory
cp -r module-isolation-system /usr/local/lib/node_modules/openclaw/skills/

# Or use symbolic link for development
ln -s /path/to/module-isolation-system ~/.openclaw/skills/module-isolation-system
```

#### Step 2: Update OpenClaw Configuration
```json
// ~/.openclaw/config.json
{
  "skills": {
    "enabled": true,
    "directory": "~/.openclaw/skills",
    "preload": ["module-isolation-system"]
  },
  "modules": {
    "isolation_enabled": true,
    "default_isolation_level": "strict",
    "memory_base_path": "memory/modules/"
  }
}
```

#### Step 3: Modify System Prompt
Add the following to your OpenClaw system prompt:

```markdown
## Module Isolation Rules

As a long-term collaborative assistant, you MUST follow these rules:

### Priority Order:
1. **Module Isolation** - Prevent context pollution between different topics/modules
2. **Memory Safety** - Ensure reliable memory management
3. **Context Continuity** - Maintain conversation flow within modules
4. **Response Speed** - Optimize performance while respecting priorities

### Workflow (5-step sequence):
1. **Judge** - Determine which module the message belongs to
2. **Load** - Load the corresponding module's memory
3. **Notify** - Notify if module switching is needed
4. **Respond** - Answer within the module's context only
5. **Archive** - Archive to the correct module's memory

### Absolute Prohibitions:
- ❌ NO shared memory between modules
- ❌ NO unclassified new topics
- ❌ NO memory contamination after switching
- ❌ NO mixing that becomes indistinguishable

### When you receive a message:
1. First determine which module it belongs to
2. If module switching is needed, notify the user
3. Respond within the module's context only
4. Archive the conversation to the correct module
```

### Advanced Integration with OpenClaw Role System

If you have an existing role system (like `roles_config.json`), integrate module isolation:

```bash
#!/bin/bash
# integrate_with_roles.sh

ROLES_CONFIG="roles_config.json"
MODULES_BASE="memory/modules"

# Map roles to modules
declare -A role_module_map=(
  ["幼师论文专版"]="thesis_writing"
  ["工程管理"]="engineering_management"
  ["财经交易"]="financial_analysis"
  ["技术部署"]="tech_operations"
  ["网站/SEO"]="web_development"
  ["系统管理"]="system_administration"
)

# Create module directories for each role
while IFS= read -r role_name; do
  if [ -n "${role_module_map[$role_name]}" ]; then
    module_name="${role_module_map[$role_name]}"
    mkdir -p "$MODULES_BASE/$module_name"
    
    # Copy role-specific templates
    if [ -d "roles/$role_name/templates" ]; then
      cp -r "roles/$role_name/templates" "$MODULES_BASE/$module_name/templates"
    fi
    
    echo "Mapped role '$role_name' to module '$module_name'"
  fi
done < <(jq -r '.roles[] | .name' "$ROLES_CONFIG")

# Create integration configuration
cat > "config/module_role_integration.json" << EOF
{
  "integration_version": "1.0",
  "last_updated": "$(date -Iseconds)",
  "mappings": {
    "幼师论文专版": "thesis_writing",
    "工程管理": "engineering_management",
    "财经交易": "financial_analysis",
    "技术部署": "tech_operations",
    "网站/SEO": "web_development",
    "系统管理": "system_administration"
  },
  "rules": {
    "role_switch_triggers_module_switch": true,
    "preserve_role_context_in_module": true,
    "synchronize_memory_paths": true
  }
}
EOF

echo "✅ Role system integration complete"
```

## Integration with Python AI Assistants

### Basic Python Wrapper

```python
#!/usr/bin/env python3
"""
Module Isolation Wrapper for Python AI Assistants
"""

import os
import json
from datetime import datetime
from typing import Dict, Optional

class ModuleIsolationWrapper:
    """Wrapper to add module isolation to any AI assistant"""
    
    def __init__(self, assistant, config: Dict):
        """
        Args:
            assistant: The AI assistant object to wrap
            config: Module isolation configuration
        """
        self.assistant = assistant
        self.config = config
        self.current_module = None
        self.module_memory = {}
        
        # Initialize module system
        self.init_module_system()
    
    def init_module_system(self):
        """Initialize module isolation system"""
        self.modules_dir = self.config.get("modules_dir", "./memory/modules")
        os.makedirs(self.modules_dir, exist_ok=True)
        
        # Load or create module definitions
        self.module_definitions = self.load_module_definitions()
    
    def load_module_definitions(self) -> Dict:
        """Load module definitions from config"""
        definitions_file = os.path.join(self.modules_dir, "module_definitions.json")
        
        if os.path.exists(definitions_file):
            with open(definitions_file) as f:
                return json.load(f)
        else:
            # Default module definitions
            default_definitions = {
                "modules": {
                    "thesis_writing": {
                        "keywords": ["thesis", "research", "paper", "academic"],
                        "description": "Academic writing and research"
                    },
                    "engineering_management": {
                        "keywords": ["engineering", "project", "construction", "report"],
                        "description": "Engineering project management"
                    },
                    "financial_analysis": {
                        "keywords": ["finance", "trading", "market", "investment"],
                        "description": "Financial market analysis"
                    },
                    "tech_operations": {
                        "keywords": ["tech", "code", "deployment", "docker", "api"],
                        "description": "Technical operations and DevOps"
                    },
                    "life_assistance": {
                        "keywords": ["travel", "shopping", "schedule", "planning"],
                        "description": "Daily life assistance"
                    }
                }
            }
            
            with open(definitions_file, "w") as f:
                json.dump(default_definitions, f, indent=2)
            
            return default_definitions
    
    def process_with_isolation(self, message: str) -> str:
        """
        Process message with module isolation
        
        Returns:
            Assistant's response with module context
        """
        # Step 1: Module judgment
        module = self.judge_module(message)
        
        # Step 2: Handle module switch
        if self.current_module and module != self.current_module:
            switch_notice = self.generate_switch_notice(self.current_module, module)
            print(switch_notice)
        
        # Step 3: Update current module
        self.current_module = module
        
        # Step 4: Load module context
        context = self.load_module_context(module)
        
        # Step 5: Generate response with module context
        response = self.generate_response(message, context)
        
        # Step 6: Archive conversation
        self.archive_conversation(module, message, response)
        
        return response
    
    def judge_module(self, message: str) -> str:
        """Determine which module the message belongs to"""
        message_lower = message.lower()
        
        for module_name, module_info in self.module_definitions["modules"].items():
            keywords = module_info.get("keywords", [])
            for keyword in keywords:
                if keyword in message_lower:
                    return module_name
        
        return "general_temporary"
    
    def load_module_context(self, module: str) -> Dict:
        """Load context for the specified module"""
        context_file = os.path.join(self.modules_dir, module, "context.json")
        
        if os.path.exists(context_file):
            with open(context_file) as f:
                return json.load(f)
        else:
            # Default context
            return {
                "module": module,
                "last_updated": datetime.now().isoformat(),
                "conversation_history": []
            }
    
    def generate_response(self, message: str, context: Dict) -> str:
        """Generate response using the wrapped assistant"""
        # Add module context to the message
        enhanced_message = f"[Module: {context['module']}]\n{message}"
        
        # Use the wrapped assistant to generate response
        response = self.assistant.generate(enhanced_message)
        
        return response
    
    def archive_conversation(self, module: str, message: str, response: str):
        """Archive the conversation to module memory"""
        archive_dir = os.path.join(self.modules_dir, module, "archive")
        os.makedirs(archive_dir, exist_ok=True)
        
        archive_entry = {
            "timestamp": datetime.now().isoformat(),
            "module": module,
            "message": message,
            "response": response
        }
        
        archive_file = os.path.join(archive_dir, f"conv_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
        
        with open(archive_file, "w") as f:
            json.dump(archive_entry, f, indent=2)
    
    def generate_switch_notice(self, old_module: str, new_module: str) -> str:
        """Generate module switch notification"""
        old_name = self.module_definitions["modules"].get(old_module, {}).get("description", old_module)
        new_name = self.module_definitions["modules"].get(new_module, {}).get("description", new_module)
        
        return f"🔄 Switching from {old_name} to {new_name}. Loading {new_name} context..."

# Usage example
if __name__ == "__main__":
    # Mock assistant class
    class MockAssistant:
        def generate(self, message):
            return f"Mock response to: {message[:50]}..."
    
    # Configuration
    config = {
        "modules_dir": "./memory/modules",
        "isolation_level": "strict"
    }
    
    # Create wrapped assistant
    mock_assistant = MockAssistant()
    isolated_assistant = ModuleIsolationWrapper(mock_assistant, config)
    
    # Test conversation
    test_messages = [
        "How to write a literature review?",
        "What about project timelines?",
        "Can you analyze market trends?"
    ]
    
    for msg in test_messages:
        print(f"\n👤 User: {msg}")
        response = isolated_assistant.process_with_isolation(msg)
        print(f"🤖 Assistant: {response}")
```

### Integration with OpenAI API

```python
import openai
from module_isolation import ModuleIsolationWrapper

class OpenAIAssistant:
    def __init__(self, api_key, model="gpt-4"):
        openai.api_key = api_key
        self.model = model
    
    def generate(self, message):
        response = openai.ChatCompletion.create(
            model=self.model,
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": message}
            ]
        )
        return response.choices[0].message.content

# Create isolated OpenAI assistant
config = {
    "modules_dir": "./memory/modules",
    "isolation_level": "strict"
}

openai_assistant = OpenAIAssistant(api_key="your-api-key")
isolated_assistant = ModuleIsolationWrapper(openai_assistant, config)

# Use the isolated assistant
response = isolated_assistant.process_with_isolation("How to structure a research paper?")
print(response)
```

## Integration with LangChain

```python
#!/usr/bin/env python3
"""
LangChain Integration for Module Isolation
"""

from langchain.llms import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
import os
from typing import List, Dict

class LangChainModuleIsolation:
    def __init__(self, api_key: str, model: str = "gpt-3.5-turbo"):
        self.llm = OpenAI(api_key=api_key, temperature=0.7, model_name=model)
        self.current_module = None
        self.module_chains = {}
        
        # Initialize module-specific chains
        self.init_module_chains()
    
    def init_module_chains(self):
        """Initialize LangChain for each module"""
        
        # Module-specific prompt templates
        module_templates = {
            "thesis_writing": """
            You are an academic writing assistant specializing in thesis and research papers.
            
            Context: {context}
            User Question: {question}
            
            Provide a detailed, academic response focused on thesis writing best practices.
            """,
            
            "engineering_management": """
            You are an engineering project management assistant.
            
            Context: {context}
            User Question: {question}
            
            Provide a practical, project-focused response with actionable advice.
            """,
            
            "financial_analysis": """
            You are a financial market analysis assistant.
            
            Context: {context}
            User Question: {question}
            
            Provide analytical, data-driven insights about financial markets.
            """,
            
            "tech_operations": """
            You are a technical operations and DevOps assistant.
            
            Context: {context}
            User Question: {question}
            
            Provide technical, implementation-focused guidance.
            """,
            
            "life_assistance": """
            You are a daily life assistance assistant.
            
            Context: {context}
            User Question: {question}
            
            Provide helpful, practical advice for daily life matters.
            """
        }
        
        # Create chains for each module
        for module, template in module_templates.items():
            prompt = PromptTemplate(
                input_variables=["context", "question"],
                template=template
            )
            chain = LLMChain(llm=self.llm, prompt=prompt)
            self.module_chains[module] = chain
    
    def judge_module(self, question: str) -> str:
        """Use LLM to judge which module the question belongs to"""
        judgment_prompt = f"""
        Classify this question into one of these modules:
        1. thesis_writing - Academic papers, research, literature reviews
        2. engineering_management - Projects, construction, reports
        3. financial_analysis - Markets, trading, investments
        4. tech_operations - Technical, DevOps, deployment
        5. life_assistance - Daily life, travel, shopping
        6. general_temporary - Everything else
        
        Question: {question}
        
        Return only the module name.
        """
        
        response = self.llm(judgment_prompt)
        module = response.strip().lower()
        
        # Validate module
        if module in self.module_chains:
            return module
        else:
            return "general_temporary"
    
    def load_module_context(self, module: str) -> str:
        """Load context for the specified module"""
        context_file = f"memory/modules/{module}/context.txt"
        
        if os.path.exists(context_file):
            with open(context_file, "r") as f:
                return f.read()
        else:
            return f"Module: {module}. No specific context available."
    
    def process_question(self, question: str) -> str:
        """Process question with module isolation"""
        
        # Step 1: Module judgment
        module = self.judge_module(question)
        
        # Step 2: Handle module switch
        if self.current_module and module != self.current_module:
            print(f"🔄 Switching from {self.current_module} to {module}")
        
        # Step 3: Update current module
        self.current_module = module
        
        # Step 4: Load module context
        context = self.load_module_context(module)
        
        # Step 5: Generate response using module-specific chain
        if module in self.module_chains:
            response = self.module_chains[module].run(
                context=context,
                question=question
            )
        else:
            # Fallback to general response
            response = self.llm(f"Question: {question}\n\nAnswer:")
        
        # Step 6: Archive (simplified)
        self.archive_interaction(module, question, response)
        
        return response
    
    def archive_interaction(self, module: str, question: str, response: str):
        """Archive the interaction"""
        archive_dir = f"memory/modules/{module}/archive"
        os.makedirs(archive_dir, exist_ok=True)
        
        archive_file = os.path.join(archive_dir, f"interaction_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")
        
        with open(archive_file, "w") as f:
            f.write(f"Question: {question}\n\n")
            f.write(f"Response: {response}\n\n")
            f.write(f"Timestamp: {datetime.now().isoformat()}\n")
            f.write(f"Module: {module}\n")

# Usage example
if __name__ == "__main__":
    from datetime import datetime
    
    # Initialize with your OpenAI API key
    isolator = LangChainModuleIsolation(api_key="your-api-key-here")
    
    # Test questions
    test_questions = [
        "How to write a literature review for a thesis?",
        "What are the key elements of a project status report?",
        "How to analyze stock market trends?",
        "Best practices for Docker container security?",
        "Planning a weekend trip to the mountains"
    ]
    
    for question in test_questions:
        print(f"\n{'='*50}")
        print(f"👤 Question: {question}")
        print(f"{'='*50}")
        
        response = isolator