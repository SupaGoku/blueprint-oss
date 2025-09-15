---
description: Create an blueprint tasks list from an approved feature spec
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Spec Creation Rules

## Overview

With the user's approval, proceed to creating a tasks list based on the current feature spec.

Explicit context requirement:

- Always read and load the complete contents of the selected spec folder into context, including every file and all subfolders (notably `sub-specs/`). Do not assume a fixed set of files; different specs may include additional documents, schemas, mocks, or checklists.

Priority override (priority 00):

- First, check @.blueprint-oss/specs/priority for any spec folders. If one or more exist, they take absolute priority (treat as priority "00").
- Priority specs follow the same dirname syntax as current specs: [PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD. The numeric prefix is ignored for precedence across folders (priority specs outrank current), but still used to order multiple priority specs.
- If multiple priority specs lack a tasks.md, confirm with the user which one to author first; if not specified, select the lowest numeric prefix (then lexical by date/name).

If no priority specs require tasks:

Current feature specs are located in @.blueprint-oss/specs/current

The specific spec dirname syntax is: [PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD

If a spec does not have a tasks.md, that means it's the most current one that this command is most likely referring to. Once you've identified the spec that needs tasks (prefer priority specs), confirm with the user.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="file-creator" name="create_tasks">

### Step 1: Create tasks.md

Use the file-creator subagent to create file: tasks.md inside of the current feature's spec folder.

<context_intake>
MUST load full spec context before drafting tasks:

- Locate the selected spec directory under `@.blueprint-oss/specs/{priority|current}/[SPEC_DIRNAME]`.
- Recursively read ALL files and folders within this spec directory, including `sub-specs/` and any nested directories.
- Include all text-based files (e.g., `.md`, `.txt`, `.yml`, `.yaml`, `.json`, `.graphql`, `.proto`, `.sql`, `.http`, `.xml`, `.toml`, `.ini`, `.csv`, `.tsv`, `.svg`, source code snippets referenced by the spec).
- For binary or very large files, capture filename, relative path, and any embedded/adjacent textual description; summarize intent and link path in the task rationale.
- Do not skip optional or unfamiliar files; skim and extract any constraints, acceptance criteria, interfaces, routes, data models, and edge cases.
- If any referenced file paths in the spec are missing, STOP and request clarification from the user before proceeding.
</context_intake>

<file_template>

  <header>
    # Spec Tasks
    
    ## GuardRails (Global Constraints)
    
    These constraints apply to ALL tasks in this spec and MUST be verified at each top-levl task completion:
    
    - **Isolation until the final task**: Only create/modify files under [SPECIFY_ALLOWED_PATHS] and [SPECIFY_ADDITIONAL_PATHS] (plus their tests/fixtures/docs/scripts). Do not alter existing files outside these boundaries until Task [N].
      - Do not alter existing files outside these boundaries until Task [N] (where N is the last task).
    - **No stubs at completion**: A top-level task is only complete when no stub, TODO, or dead code remains in the affected files.
    - **Style compliance**: All tasks require:
      - Code formatting per language standards
      - Clean lint with no warnings
      - Documentation builds without errors
      - All tests passing
    - **Incremental verification**: Each task must be independently verifiable and not break existing functionality
  </header>
</file_template>

<task_structure>
<major_tasks>

- count: 3-7 (prefer more granular tasks)
  - There can can be more if required, this is just a guideline
- format: numbered checklist with detailed descriptions
- grouping: by feature, component, or logical workflow phase
- verbosity: each task should clearly state WHAT is being done, WHERE, and WHY
  </major_tasks>
  <subtasks>
- count: 5-12 per major task (more granular breakdown)
- format: decimal notation (1.1, 1.2, etc.)
  - There can can be more if required, this is just a guideline
- first_subtask: research/analysis or implementation setup
- middle_subtasks: incremental implementation steps with clear boundaries
- penultimate_subtask: integration and edge case handling
- last_subtask: verify code quality per language standards
  </subtasks>
  <sub_subtasks>
- optional: use when subtask requires further breakdown
- count: 2-5 per subtask (when needed)
- format: triple decimal notation (1.1.1, 1.1.2, etc.)
- use_when: subtask involves multiple distinct operations or complex logic
- indent: additional level for clarity
  </sub_subtasks>
  </task_structure>

<task_template>

## Tasks

- [ ] 1. [MAJOR_TASK_TITLE]: [DETAILED_DESCRIPTION_OF_WHAT_AND_WHY]

  **Scope**: [FILES_AND_MODULES_AFFECTED]
  **Dependencies**: [WHAT_THIS_TASK_DEPENDS_ON]
  **Deliverables**: [SPECIFIC_OUTPUTS_OR_CHANGES]

  - [ ] 1.1 Research and analyze [SPECIFIC_AREA] to understand [GOAL]
    - [ ] 1.1.1 Review existing [CODEBASE/DOCUMENTATION] for [CONTEXT]
    - [ ] 1.1.2 Identify [DEPENDENCIES/CONSTRAINTS/PATTERNS]
    - [ ] 1.1.3 Document findings and design decisions
  - [ ] 1.2 Design [COMPONENT/INTERFACE/STRUCTURE] with consideration for [CONSTRAINTS]
    - [ ] 1.2.1 Create interface definitions for [COMPONENT]
    - [ ] 1.2.2 Define data structures and types
    - [ ] 1.2.3 Map out component interactions and data flow
  - [ ] 1.3 Implement [SPECIFIC_FUNCTIONALITY] in [LOCATION]
    - [ ] 1.3.1 Create base structure and boilerplate
    - [ ] 1.3.2 Implement core logic for [FEATURE]
    - [ ] 1.3.3 Add error handling and validation
  - [ ] 1.4 Add comprehensive unit tests for [COMPONENT]
  - [ ] 1.5 Implement [ADDITIONAL_FUNCTIONALITY] with [SPECIFIC_REQUIREMENTS]
    - [ ] 1.5.1 [SPECIFIC_SUB_FEATURE_1]
    - [ ] 1.5.2 [SPECIFIC_SUB_FEATURE_2]
  - [ ] 1.6 Handle edge cases: [LIST_KEY_EDGE_CASES]
  - [ ] 1.7 Add integration tests verifying [INTEGRATION_POINTS]
  - [ ] 1.8 Update documentation for [AFFECTED_APIS/COMPONENTS]
  - [ ] 1.9 Verify code quality and standards compliance

  **Post-Flight Check for Task 1**:

  - [ ] **GuardRails Compliance**: Verify all changes are within allowed paths
  - [ ] **Sanity Check**: [SPECIFIC_VERIFICATION_THAT_TASK_ACHIEVED_ITS_GOAL]
  - [ ] **Definition of Done**:
    - All subtasks completed
    - [SPECIFIC_ACCEPTANCE_CRITERIA_1]
    - [SPECIFIC_ACCEPTANCE_CRITERIA_2]
    - No TODOs or stubs remaining in modified files
    - Tests passing with >X% coverage for new code
    - Documentation updated and builds cleanly

- [ ] 2. [MAJOR_TASK_TITLE]: [DETAILED_DESCRIPTION]

     **Scope**: [FILES_AND_MODULES_AFFECTED]
     **Dependencies**: Task 1 completion
     **Deliverables**: [SPECIFIC_OUTPUTS]

  - [ ] 2.1 [SETUP_OR_ANALYSIS_STEP]
  - [ ] 2.2 [IMPLEMENTATION_STEP_WITH_DETAILS]
    - [ ] 2.2.1 [DETAILED_SUB_STEP_IF_COMPLEX]
    - [ ] 2.2.2 [ANOTHER_SUB_STEP_IF_NEEDED]
  - [ ] 2.3 [IMPLEMENTATION_STEP_WITH_DETAILS]
  - [ ] 2.4 [TEST_IMPLEMENTATION]
    - [ ] 2.4.1 Unit tests for [COMPONENT_A]
    - [ ] 2.4.2 Unit tests for [COMPONENT_B]
    - [ ] 2.4.3 Integration tests for [INTERACTION]
  - [ ] 2.5 [ADDITIONAL_IMPLEMENTATION]
  - [ ] 2.6 [EDGE_CASE_HANDLING]
  - [ ] 2.7 [INTEGRATION_OR_VERIFICATION]
  - [ ] 2.8 Verify code quality and standards compliance
        **Post-Flight Check for Task 2**:
  - [ ] **GuardRails Compliance**: Verify isolation boundaries maintained
  - [ ] **Sanity Check**: [SPECIFIC_VERIFICATION]
  - [ ] **Definition of Done**: - All subtasks completed - [SPECIFIC_ACCEPTANCE_CRITERIA] - Integration with Task 1 components verified - Performance benchmarks met (if applicable)
        </task_template>

<ordering_principles>

- Consider technical dependencies
- Follow language-specific workflow from style guides
- Group related functionality
- Build incrementally
  </ordering_principles>

</step>

<step number="2" name="execution_readiness">

### Step 2: Execution Readiness Check

Evaluate readiness to begin implementation by presenting the first task summary and requesting user confirmation to proceed.

<readiness_summary>
<present_to_user> - Spec name and description - First task summary from tasks.md - Estimated complexity/scope - Key deliverables for task 1
</present_to_user>
</readiness_summary>

<execution_prompt>
PROMPT: "The spec planning is complete. The first task is:

**Task 1:** [FIRST_TASK_TITLE]
[BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]

Would you like me to proceed with implementing Task 1? I will focus only on this first task and its subtasks unless you specify otherwise.

Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
</execution_prompt>

<execution_flow>
IF user_confirms_yes:
REFERENCE: @.blueprint-oss/instructions/core/execute-tasks.md
FOCUS: Only Task 1 and its subtasks
CONSTRAINT: Do not proceed to additional tasks without explicit user request
ELSE:
WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
