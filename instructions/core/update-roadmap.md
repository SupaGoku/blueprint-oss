---
description: Roadmap Update Rules for blueprint
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Roadmap Update Rules

## Overview

Modify or extend the product roadmap by adding phases/features, reprioritizing, or editing items while preserving structure and conventions.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="load_context">

### Step 1: Load Context

Read the following for alignment, if not already in context: @.blueprint-oss/product/mission-lite.md, @.blueprint-oss/product/tech-stack.md, and @.blueprint-oss/product/roadmap.md.

<error_handling>
IF @.blueprint-oss/product/roadmap.md does not exist:
FAIL with: "roadmap.md not found. Run Plan Product (Step 6) to create it first."
</error_handling>

</step>

<step number="2" subagent="context-fetcher" name="change_request">

### Step 2: Change Request

Ask the user to choose one action: add_phase, add_feature, edit_feature, reprioritize, or mark_complete. Collect minimal required fields.

<field_matrix>

- add_phase: name, goal, success_criteria, features[feature, description, effort], dependencies(optional)
- add_feature: target_phase, feature, description, effort, dependencies(optional)
- edit_feature: phase, feature_id_or_title, fields_to_change
- reprioritize: list of feature identifiers in new order (within a phase)
- mark_complete: phase, feature_id_or_title
  </field_matrix>

</step>

<step number="3" subagent="file-creator" name="prepare_patch">

### Step 3: Prepare Patch

Create an in-memory patch that minimally edits @.blueprint-oss/product/roadmap.md while preserving headings and existing content. Use the phase template from Plan Product (Step 6):

<phase_template>

## Phase [NUMBER]: [NAME]

**Goal:** [PHASE_GOAL]
**Success Criteria:** [MEASURABLE_CRITERIA]

### Features

- [ ] [FEATURE] - [DESCRIPTION] `[EFFORT]`

### Dependencies

- [DEPENDENCY]
  </phase_template>

<effort_scale>
XS=1d, S=2-3d, M=1w, L=2w, XL=3+w
</effort_scale>

</step>

<step number="4" subagent="file-creator" name="apply_changes">

### Step 4: Apply Changes

Write the updated content back to @.blueprint-oss/product/roadmap.md with these rules:

<rules>
- Preserve existing phases and items; only modify targets.
- Maintain checkboxes: use "- [ ]" for open, "- [x]" when marking complete.
- Append new phases/features at the correct phase and keep alphabetical order within features only if no explicit priority is provided.
- Do not change effort tags unless explicitly requested.
</rules>

</step>

<step number="5" subagent="context-fetcher" name="post_validation">

### Step 5: Post-Validation

Re-read @.blueprint-oss/product/roadmap.md and verify:

<checks>
- All phases numbered sequentially starting at 1.
- Every feature has an effort tag `[XS|S|M|L|XL]`.
- No duplicate feature titles within the same phase.
</checks>

If any check fails, report the issue and propose a fix before concluding.

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
