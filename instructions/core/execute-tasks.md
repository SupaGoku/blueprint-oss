---
description: Rules to initiate execution of a set of tasks using blueprint
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

### Spec Selection

Priority override (priority 00):

- First, check @.blueprint-oss/specs/priority for any spec folders. If one or more exist, they take absolute priority (treat as priority "00").
- Priority specs use the same dirname syntax as current specs: [PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD. The numeric prefix is ignored for precedence (all specs in priority outrank current), but still used to order multiple specs in priority.
- If multiple priority specs exist, confirm with the user which to execute; if not specified, select the lowest numeric prefix (then lexical by date/name).
- If the selected priority spec has no tasks.md, STOP and alert the user to run /create-tasks for that priority before execution.

Otherwise (no priority specs present):

Current feature specs are located in @.blueprint-oss/specs/current

The specific spec dirname syntax is: [PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD
Check these specs sequentially, based on the priority

If a spec does not have a tasks.md, that means it's not ready for execution.
STOP looking for specs if you run into a spec with missing tasks.md. Something has gone wrong or the user did something.
STOP exeuction and alert the user letting them know the [spec-name] is missing tasks.md

When a spec is done, it's moved to the @.blueprint-oss/specs/done folder

Once you're identified the spec has tasks, confirm with the user.

### Execute

Execute tasks for a given spec following three distinct phases:

1. Pre-execution setup (Steps 1–2)
2. Task execution + Post-execution (Steps 3–4)
3. Verification loop (Step 5)

**IMPORTANT**: All three phases MUST be completed. Do not stop after phase 2.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

## Phase 1: Pre-Execution Setup

<step number="1" name="task_assignment">

### Step 1: Task Assignment

Identify which tasks to execute from the spec (using spec_srd_reference file path and optional specific_tasks array), defaulting to the next uncompleted parent task if not specified.

<task_selection>
<explicit>user specifies exact task(s)</explicit>
<implicit>find next uncompleted task in tasks.md</implicit>
</task_selection>

<instructions>
  ACTION: Identify task(s) to execute
  DEFAULT: Select next uncompleted parent task if not specified
  CONFIRM: Task selection with user
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="context_analysis">

### Step 2: Context Analysis

Use the context-fetcher subagent to gather minimal context for task understanding by always loading spec tasks.md, and conditionally loading @.blueprint-oss/product/mission-lite.md, spec-lite.md, and sub-specs/technical-spec.md if not already in context.

<instructions>
  ACTION: Use context-fetcher subagent to:
    - REQUEST: "Get product pitch from mission-lite.md"
    - REQUEST: "Get spec summary from spec-lite.md"
    - REQUEST: "Get technical approach from technical-spec.md"
  PROCESS: Returned information
</instructions>

<context_gathering>
<essential_docs> - tasks.md for task breakdown
</essential_docs>
<conditional_docs> - mission-lite.md for product alignment - spec-lite.md for feature summary - technical-spec.md for implementation details
</conditional_docs>
</context_gathering>

</step>

## Phase 2: Task Execution + Post-Execution

<step number="3" name="task_execution_loop">

### Step 3: Task Execution Loop

**IMPORTANT**: This is a loop. Execute ALL assigned tasks before proceeding to Phase 3.

Execute all assigned parent tasks and their subtasks using @.blueprint-oss/instructions/core/execute-task.md instructions, continuing until all tasks are complete.

<execution_flow>
LOAD @.blueprint-oss/instructions/core/execute-task.md ONCE

FOR each parent_task assigned in Step 1:
EXECUTE instructions from execute-task.md with: - parent_task_number - all associated subtasks
WAIT for task completion
UPDATE tasks.md status
END FOR

**IMPORTANT**: After this loop completes, CONTINUE to Step 4 (Post-Execution Tasks). Do not stop here.
</execution_flow>

<loop_logic>
<continue_conditions> - More unfinished parent tasks exist - User has not requested stop
</continue_conditions>
<exit_conditions> - All assigned tasks marked complete - User requests early termination - Blocking issue prevents continuation
</exit_conditions>
</loop_logic>

<task_status_check>
AFTER each task execution:
CHECK tasks.md for remaining tasks
IF all assigned tasks complete:
PROCEED to next step
ELSE:
CONTINUE with next task
</task_status_check>

<instructions>
  ACTION: Load execute-task.md instructions once at start
  REUSE: Same instructions for each parent task iteration
  LOOP: Through all assigned parent tasks
  UPDATE: Task status after each completion
  VERIFY: All tasks complete before proceeding
  HANDLE: Blocking issues appropriately
  **IMPORTANT**: When all tasks complete, proceed to Step 4 (Post-Execution Tasks)
</instructions>

</step>

<step number="4" name="post_execution_tasks">

### Step 4: Post-Execution Tasks

**CRITICAL**: Run these preparatory wrap-up steps before entering the verification loop.

After all tasks in tasks.md have been implemented, use @.blueprint-oss/instructions/core/post-execution-tasks.md to run our standard completion steps for a new feature.

<instructions>
  LOAD: @.blueprint-oss/instructions/core/post-execution-tasks.md once
  ACTION: execute all steps in the post-execution-tasks.md process_flow.
  **IMPORTANT**: This includes:
    - Running language-specific quality checks
    - Verifying task completion
    - Updating roadmap (if applicable)
    - Creating recap document
    - Generating completion summary
    - Playing notification sound
</instructions>

</step>

## Phase 3: Verification Loop

<step number="5" name="verification_loop">

### Step 5: Verification Loop (Researcher Subagents)

Run a verification pass using researcher subagent(s) with a clean slate: provide ONLY the completed spec and current tasks.md as initial context. The subagent(s) must determine if tasks marked complete are truly complete, with no TODOs, stubs, dead code, or missing behaviors. Any missed implementations must be turned into new top‑level tasks (with detailed subtasks and code references) appended to tasks.md by the subagent(s). The only response to the primary agent is a binary decision: MORE_WORK or FEATURE_COMPLETE.

<agent_selection>
- Use `frontend-researcher` when scope involves UI/components/routes/state/style/accessibility.
- Use `backend-researcher` when scope involves APIs/services/workers/db/auth/integrations.
- Use BOTH when scope spans full‑stack or uncertain.
</agent_selection>

<present_to_user>
- Selected agent(s): frontend-researcher, backend-researcher, or both
- Rationale for selection based on spec scope
</present_to_user>

<initial_context>
- `@.blueprint-oss/specs/[...]/spec.md` (required)
- `@.blueprint-oss/specs/[...]/tasks.md` (required)
- No other files are preloaded. The subagent must discover and read repo code as needed.
</initial_context>

<constraints>
- Subagent(s) MUST NOT modify code; documentation/tasks only.
- Findings must include concrete evidence: file paths, line ranges, routes/selectors, or UI states.
- Each missed item must be added as a new top‑level task with detailed subtasks and acceptance criteria matching our tasks.md style.
</constraints>

<subagent_outputs>
- Report: concise summary of verification scope and confidence.
- New tasks: appended directly to tasks.md by the subagent(s).
- Primary response: EXACTLY one of: `MORE_WORK` or `FEATURE_COMPLETE`.
</subagent_outputs>

<deliverables>
- EDIT: `@.blueprint-oss/specs/[...]/tasks.md` — append new tasks at end; DO NOT reorder existing items.
</deliverables>

<step number="5a" subagent="backend-researcher" name="run_backend_verification_if_selected">
RUN ONLY IF backend-researcher was selected.
</step>

<step number="5b" subagent="frontend-researcher" name="run_frontend_verification_if_selected">
RUN ONLY IF frontend-researcher was selected.
</step>

<verification_flow>
IF subagent(s) return `MORE_WORK`:
  RECURSE to Step 3 (Task Execution Loop)
  THEN run Step 4 (Post-Execution Tasks) before re-entering Step 5
ELSE IF `FEATURE_COMPLETE`:
  PROCEED to Post-Flight Checks
</verification_flow>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
