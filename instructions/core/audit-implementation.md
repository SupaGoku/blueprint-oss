---
description: Audit a spec marked complete against implementation; log gaps and create tasks (frontend, backend, or both)
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Audit Implementation (Spec → Code)

Use this when a feature spec has been marked “complete” by an LLM or implementer. Run a focused audit using the most appropriate researcher agent(s) with only the spec documents as initial context. The researcher agent(s) must independently discover and read code to verify the implementation, then report any gaps. Finally, convert each gap into actionable tasks in the spec’s `tasks.md` with detailed subtasks and acceptance criteria.

Key goals:

- Verify the code actually implements the approved spec.
- Identify missing, partial, or incorrect behaviors; risky shortcuts; absent tests/docs.
- Translate findings into top-level tasks with clear, verifiable subtasks.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="select_target_spec">

### Step 1: Select Target Spec

Locate the spec folder to audit using the same precedence as other core flows:

- First, check `.blueprint-oss/specs/priority/` for any spec folders; if present, choose the lowest numeric prefix (then lexical by date/name).
- Otherwise, use `.blueprint-oss/specs/current/` and select the lowest numeric prefix (then lexical by date/name) representing the most recent “complete” spec intended for delivery.

Confirm the selected spec folder path for subsequent steps:

<present_to_user>
- Selected spec folder: `.blueprint-oss/specs/[priority|current]/[SPEC_DIR]/`
- Reason for selection (priority or most-recent current)
</present_to_user>

</step>

<step number="2" name="agent_selection_and_audit">

### Step 2: Agent Selection and Audit (spec-only initial context)

Determine which researcher agent(s) to use:

- Use `frontend-researcher` when the spec includes UI components, pages/routes, client-side state, styling, or accessibility.
- Use `backend-researcher` when the spec includes APIs, services, workers, database models/migrations, auth, or integrations.
- Use BOTH when the spec spans full-stack concerns or uncertainty exists.

Record the routing decision and rationale:

<present_to_user>
- Selected agent(s): frontend-researcher, backend-researcher, or both
- Rationale for selection based on spec scope
</present_to_user>

For each selected agent, run an audit with ONLY the spec documents below as initial context. Do not preload any other files (no tasks, code, or product docs). Each subagent must independently read the repository to validate implementation.

<initial_context>
- `@.blueprint-oss/specs/[...]/spec.md` (required)
- `@.blueprint-oss/specs/[...]/spec-lite.md` (if exists)
- `@.blueprint-oss/specs/[...]/sub-specs/*.md` (if exists)
</initial_context>

Constraints for each subagent:

- Do not modify code or configuration; this audit is documentation-only.
- Discover relevant code by reading the repo (search by feature keywords, endpoints, modules referenced in spec).
- Prefer file:line references and concrete evidence over general observations.
- Classify each finding by category and severity.

Required output from each subagent (Audit Report):

- Summary: one-paragraph overview of audit scope and confidence.
- Findings: list items with:
  - Category: missing-feature | partial-implementation | incorrect-behavior | test-gap | doc-gap | performance-risk | security-risk | migration-gap | a11y-gap (frontend)
  - Severity: critical | high | medium | low
  - Evidence: file paths, line ranges, routes, selectors, or UI states; expected vs. actual per spec.
  - Impact: user-visible or system-level effect.
  - Recommendation: what to change (high level; no code).
- Coverage: what parts of the spec were verified vs. not (and why).

<deliverable>
SAVE: `@.blueprint-oss/specs/[...]/audit-report.md`
CONTENT: If both agents are used, produce a consolidated report with labeled sections (Frontend, Backend); otherwise produce a single-section report.
</deliverable>

<step number="2a" subagent="backend-researcher" name="run_backend_audit_if_selected">
RUN ONLY IF backend-researcher was selected in Step 2.
</step>

<step number="2b" subagent="frontend-researcher" name="run_frontend_audit_if_selected">
RUN ONLY IF frontend-researcher was selected in Step 2.
</step>

</step>

<step number="3" name="ensure_tasks_file">

### Step 3: Ensure tasks.md Exists

Locate `tasks.md` in the selected spec folder. If missing:

- STOP and create it by running `@.blueprint-oss/instructions/core/create-tasks.md` (or ask the user to run `/create-tasks`), then resume this audit flow.

Once `tasks.md` exists, proceed.

</step>

<step number="4" name="translate_findings_to_tasks">

### Step 4: Translate Findings to Tasks

For each finding in the Audit Report, add a new top-level task to `tasks.md` with detailed subtasks. Follow this structure:

- Top-level task format: `- [ ] N. [TITLE]: [WHAT + WHY]`
  - Scope: files/modules affected
  - Dependencies: upstream tasks or migrations
  - Deliverables: artifacts or verifications expected
- Subtasks (5–12 typical):
  - Begin with analysis/verification (reproduce the issue, capture inputs/outputs)
  - Implementation steps grouped by logical boundaries
  - Tests: unit/integration/e2e as appropriate (include concrete assertions)
  - Docs: README/ADR/CHANGELOG updates where relevant
  - Final verification: acceptance criteria checklist

Acceptance Criteria per task should include:

- Expected behavior per spec with example inputs/outputs
- Tests exist and pass (list test files or suites)
- No TODOs or stubs remain in modified files
- Lint/type checks clean; formatting applied
- Backwards compatibility and migrations verified (if applicable)

Ordering guidance:

- Sort new tasks primarily by severity (critical → low), secondarily by execution dependencies.

<edit_tasks>
FILE: `@.blueprint-oss/specs/[...]/tasks.md`
ACTION: Append new numbered top-level tasks and their subtasks; do not reorder existing tasks.
</edit_tasks>

</step>

<step number="5" name="present_summary">

### Step 5: Present Summary to User

Provide a concise summary:

- Spec audited: folder path
- Findings by severity: counts
- New tasks added: count and first three titles
- Any blockers or areas not verifiable and why

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
