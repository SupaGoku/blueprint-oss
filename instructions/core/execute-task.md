---
description: Rules to execute a task and its sub-tasks using blueprint
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

Execute a specific task along with its sub-tasks systematically.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="task_understanding">

### Step 1: Task Understanding

Read and analyze the given parent task and all its sub-tasks from tasks.md to gain complete understanding of what needs to be built.

<task_analysis>
<read_from_tasks_md> - Parent task description - All sub-task descriptions - Task dependencies - Expected outcomes
</read_from_tasks_md>
</task_analysis>

<instructions>
  ACTION: Read the specific parent task and all its sub-tasks
  ANALYZE: Full scope of implementation required
  UNDERSTAND: Dependencies and expected deliverables
  NOTE: Implementation requirements for each sub-task
</instructions>

</step>

<step number="2" name="technical_spec_review">

### Step 2: Technical Specification Review

Search and extract relevant sections from technical-spec.md to understand the technical implementation approach for this task.

<selective_reading>
<search_technical_spec>
FIND sections in technical-spec.md related to: - Current task functionality - Implementation approach for this feature - Integration requirements - Performance criteria
</search_technical_spec>
</selective_reading>

<instructions>
  ACTION: Search technical-spec.md for task-relevant sections
  EXTRACT: Only implementation details for current task
  SKIP: Unrelated technical specifications
  FOCUS: Technical approach for this specific feature
</instructions>

</step>

<step number="3" subagent="context-fetcher" name="best_practices_review">

### Step 3: Best Practices Review

Use the context-fetcher subagent to retrieve relevant sections from @.blueprint-oss/standards/best-practices.md that apply to the current task's technology stack and feature type.

<selective_reading>
<search_best_practices>
FIND sections relevant to: - Task's technology stack - Feature type being implemented - Code quality standards - Code organization patterns
</search_best_practices>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find best practices sections relevant to:
            - Task's technology stack: [CURRENT_TECH]
            - Feature type: [CURRENT_FEATURE_TYPE]
            - Code quality standards
            - Code organization patterns"
  PROCESS: Returned best practices
  APPLY: Relevant patterns to implementation
</instructions>

</step>

<step number="4" subagent="context-fetcher" name="code_style_review">

### Step 4: Code Style Review

Use the context-fetcher subagent to retrieve relevant code style rules from @.blueprint-oss/standards/code-style/[language]-style.md for the languages and file types being used in this task.

<selective_reading>
<search_code_style>
FIND style rules for: - Languages used in this task - File types being modified - Component patterns being implemented - Language-specific workflow and verification steps
</search_code_style>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find code style rules for:
            - Languages: [LANGUAGES_IN_TASK]
            - File types: [FILE_TYPES_BEING_MODIFIED]
            - Component patterns: [PATTERNS_BEING_IMPLEMENTED]
            - Language-specific workflow and verification"
  PROCESS: Returned style rules
  APPLY: Relevant formatting, patterns, and workflow
</instructions>

</step>

<step number="5" name="task_execution">

### Step 5: Task and Sub-task Execution

Execute the parent task and all sub-tasks in order.

<typical_task_structure>
<first_subtask>Setup or planning steps</first_subtask>
</typical_task_structure>

<execution_order>
<subtask_1_setup>
IF sub-task 1 is setup/planning: - Prepare implementation environment - Review requirements and dependencies - Plan implementation approach - Mark sub-task 1 complete
</subtask_1_setup>

<middle_subtasks_implementation>
FOR each implementation sub-task (2 through n-1): - Implement the specific functionality - Follow language-specific workflow from style guide - Ensure code quality standards are met - Refactor as needed for clarity - Mark sub-task complete
</middle_subtasks_implementation>

<final_subtask_verification>
IF final sub-task is "Verify code quality and standards": - Run language-specific checks from style guide - Fix any issues or warnings - Ensure code meets all standards - Mark final sub-task complete
</final_subtask_verification>
</execution_order>

<quality_management>
<code_standards> - Follow language-specific style guide - Apply formatting rules - Ensure no warnings or errors
</code_standards>
<workflow_adherence> - Follow workflow defined in language style guide - Complete all verification steps - Maintain code quality throughout
</workflow_adherence>
</quality_management>

<instructions>
  ACTION: Execute sub-tasks in their defined order
  RECOGNIZE: First sub-task typically handles setup/planning
  IMPLEMENT: Middle sub-tasks build functionality
  VERIFY: Final sub-task ensures code quality per language standards
  UPDATE: Mark each sub-task complete as finished
</instructions>

</step>

<step number="6" name="task_code_verification">

### Step 6: Task-Specific Code Verification

Run language-specific verification checks as defined in @.blueprint-oss/standards/code-style/[language]-style.md to ensure the implementation meets all quality standards.

<language_specific_verification>
<check_workflow> - Follow verification workflow from language style guide - Run appropriate language-specific commands - Check for warnings, errors, or style violations
</check_workflow>
<quality_gates> - No compilation errors - No warnings (unless explicitly justified) - Code formatting compliance - Style guide adherence
</quality_gates>
</language_specific_verification>

<final_verification>
IF any issues found: - Fix the specific issue - Re-run verification checks
ELSE: - Confirm all code quality checks pass - Ready to proceed
</final_verification>

<instructions>
  ACTION: Run language-specific checks from style guide
  EXECUTE: Verification workflow for current language
  PROCESS: Fix any warnings or errors
  VERIFY: Code meets all quality standards
  CONFIRM: Task implementation is complete
</instructions>

</step>

<step number="7" name="task_status_updates">

### Step 7: Mark this task and sub-tasks complete

IMPORTANT: In the tasks.md file, mark this task and its sub-tasks complete by updating each task checkbox to [x].

<update_format>
<completed>- [x] Task description</completed>
<incomplete>- [ ] Task description</incomplete>
<blocked> - [ ] Task description
⚠️ Blocking issue: [DESCRIPTION]
</blocked>
</update_format>

<blocking_criteria>
<attempts>maximum 3 different approaches</attempts>
<action>document blocking issue</action>
<emoji>⚠️</emoji>
</blocking_criteria>

<instructions>
  ACTION: Update tasks.md after each task completion
  MARK: [x] for completed items immediately
  DOCUMENT: Blocking issues with ⚠️ emoji
  LIMIT: 3 attempts before marking as blocked
</instructions>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
