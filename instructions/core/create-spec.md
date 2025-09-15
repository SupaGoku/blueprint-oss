---
description: Spec Creation Rules for blueprint
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Spec Creation Rules

## Overview

Generate detailed feature specifications aligned with product roadmap and mission.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="spec_initiation">

### Step 1: Spec Initiation

Use the context-fetcher subagent to identify spec initiation method by either finding the next uncompleted roadmap item when user asks "what's next?" or accepting a specific spec idea from the user.

<option_a_flow>
<trigger_phrases> - "what's next?"
</trigger_phrases>
<actions> 1. CHECK @.blueprint-oss/product/roadmap.md 2. FIND next uncompleted item 3. SUGGEST item to user 4. WAIT for approval
</actions>
</option_a_flow>

<option_b_flow>
<trigger>user describes specific spec idea</trigger>
<accept>any format, length, or detail level</accept>
<proceed>to context gathering</proceed>
</option_b_flow>

</step>

<step number="2" subagent="context-fetcher" name="context_gathering">

### Step 2: Context Gathering (Conditional)

Use the context-fetcher subagent to read @.blueprint-oss/product/mission-lite.md and @.blueprint-oss/product/tech-stack.md only if not already in context to ensure minimal context for spec alignment.

<conditional_logic>
IF both mission-lite.md AND tech-stack.md already read in current context:
SKIP this entire step
PROCEED to step 3
ELSE:
READ only files not already in context: - mission-lite.md (if not in context) - tech-stack.md (if not in context)
CONTINUE with context analysis
</conditional_logic>

<context_analysis>
<mission_lite>core product purpose and value</mission_lite>
<tech_stack>technical requirements</tech_stack>
</context_analysis>

</step>

<step number="3" subagent="context-fetcher" name="requirements_clarification">

### Step 3: Requirements Clarification

Use the context-fetcher subagent to clarify scope boundaries and technical considerations by asking numbered questions as needed to ensure clear requirements before proceeding.

<clarification_areas>
<scope> - in_scope: what is included - out_of_scope: what is excluded (optional)
</scope>
<technical> - functionality specifics - UI/UX requirements - integration points
</technical>
</clarification_areas>

<decision_tree>
IF clarification_needed:
ASK numbered_questions
WAIT for_user_response
ELSE:
PROCEED to_date_determination
</decision_tree>

</step>

<step number="4" subagent="date-checker" name="date_determination">

### Step 4: Date and Priority Determination

Determine the current date in YYYY-MM-DD format for folder naming.
Find the next lowest number in priority for the specs/current folder.

<subagent_output>
The date-checker subagent will provide the current date in YYYY-MM-DD format at the end of its response. Store this date for use in folder naming in step 5.
</subagent_output>

</step>

<step number="5" subagent="file-creator" name="spec_folder_creation">

### Step 5: Spec Folder Creation

Use the file-creator subagent to create directory: .blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD/ using the date and priority number from step 4.

Use kebab-case for spec name. Maximum 5 words in name.

<folder_naming>
<format>YYYY-MM-DD-spec-name</format>
<date>use stored date from step 4</date>
<name_constraints> - max_words: 5 - style: kebab-case - descriptive: true
</name_constraints>
</folder_naming>

<example_names>

- 2025-03-15-password-reset-flow
- 2025-03-16-user-profile-dashboard
- 2025-03-17-api-rate-limiting
  </example_names>

</step>

<step number="6" subagent="file-creator" name="create_spec_md">

### Step 6: Create spec.md

Use the file-creator subagent to create the file: .blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD//spec.md using this template:

<file_template>

  <header>
    # Spec Requirements Document

    > Spec: [SPEC_NAME]
    > Created: [CURRENT_DATE]

  </header>
  <required_sections>
    - Overview
    - User Stories
    - Spec Scope
    - Out of Scope
    - Expected Deliverable
  </required_sections>
</file_template>

<section name="overview">
  <template>
    ## Overview

    [1-2_SENTENCE_GOAL_AND_OBJECTIVE]

  </template>
  <constraints>
    - length: 1-2 sentences
    - content: goal and objective
  </constraints>
  <example>
    Implement a secure password reset functionality that allows users to regain account access through email verification. This feature will reduce support ticket volume and improve user experience by providing self-service account recovery.
  </example>
</section>

<section name="user_stories">
  <template>
    ## User Stories

    ### [STORY_TITLE]

    As a [USER_TYPE], I want to [ACTION], so that [BENEFIT].

    [DETAILED_WORKFLOW_DESCRIPTION]

  </template>
  <constraints>
    - count: 1-3 stories
    - include: workflow and problem solved
    - format: title + story + details
  </constraints>
</section>

<section name="spec_scope">
  <template>
    ## Spec Scope

    1. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
    2. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]

  </template>
  <constraints>
    - count: 1-5 features
    - format: numbered list
    - description: one sentence each
  </constraints>
</section>

<section name="out_of_scope">
  <template>
    ## Out of Scope

    - [EXCLUDED_FUNCTIONALITY_1]
    - [EXCLUDED_FUNCTIONALITY_2]

  </template>
  <purpose>explicitly exclude functionalities</purpose>
</section>

<section name="expected_deliverable">
  <template>
    ## Expected Deliverable

    1. [VERIFIABLE_OUTCOME_1]
    2. [VERIFIABLE_OUTCOME_2]

  </template>
  <constraints>
    - count: 1-3 expectations
    - focus: verifiable deliverables
  </constraints>
</section>

</step>

<step number="7" subagent="file-creator" name="create_spec_lite_md">

### Step 7: Create spec-lite.md

Use the file-creator subagent to create the file: .blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD//spec-lite.md for the purpose of establishing a condensed spec for efficient AI context usage.

<file_template>

  <header>
    # Spec Summary (Lite)
  </header>
</file_template>

<content_structure>
<spec_summary> - source: Step 6 spec.md overview section - length: 1-3 sentences - content: core goal and objective of the feature
</spec_summary>
</content_structure>

<content_template>
[1-3_SENTENCES_SUMMARIZING_SPEC_GOAL_AND_OBJECTIVE]
</content_template>

<example>
  Implement secure password reset via email verification to reduce support tickets and enable self-service account recovery. Users can request a reset link, receive a time-limited token via email, and set a new password following security best practices.
</example>

</step>

<step number="8" subagent="file-creator" name="create_technical_spec">

### Step 8: Create Technical Specification

Use the file-creator subagent to create the file: sub-specs/technical-spec.md using this template:

<file_template>

  <header>
    # Technical Specification

    This is the technical specification for the spec detailed in @.blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD//spec.md

  </header>
</file_template>

<spec_sections>
<technical_requirements> - functionality details - UI/UX specifications - integration requirements - performance criteria
</technical_requirements>
<external_dependencies_conditional> - only include if new dependencies needed - new libraries/packages - justification for each - version requirements
</external_dependencies_conditional>
</spec_sections>

<example_template>

## Technical Requirements

- [SPECIFIC_TECHNICAL_REQUIREMENT]
- [SPECIFIC_TECHNICAL_REQUIREMENT]

## External Dependencies (Conditional)

[ONLY_IF_NEW_DEPENDENCIES_NEEDED]

- **[LIBRARY_NAME]** - [PURPOSE]
- **Justification:** [REASON_FOR_INCLUSION]
  </example_template>

<conditional_logic>
IF spec_requires_new_external_dependencies:
INCLUDE "External Dependencies" section
ELSE:
OMIT section entirely
</conditional_logic>

</step>

<step number="9" subagent="file-creator" name="create_database_schema">

### Step 9: Create Database Schema (Conditional)

Use the file-creator subagent to create the file: sub-specs/database-schema.md ONLY IF database changes needed for this task.

<decision_tree>
IF spec_requires_database_changes:
CREATE sub-specs/database-schema.md
ELSE:
SKIP this_step
</decision_tree>

<file_template>

  <header>
    # Database Schema

    This is the database schema implementation for the spec detailed in @.blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD//spec.md

  </header>
</file_template>

<schema_sections>
<changes> - new tables - new columns - modifications - migrations
</changes>
<specifications> - exact SQL or migration syntax - indexes and constraints - foreign key relationships
</specifications>
<rationale> - reason for each change - performance considerations - data integrity rules
</rationale>
</schema_sections>

</step>

<step number="10" subagent="file-creator" name="create_api_spec">

### Step 10: Create API Specification (Conditional)

Use the file-creator subagent to create file: sub-specs/api-spec.md ONLY IF API changes needed.

<decision_tree>
IF spec_requires_api_changes:
CREATE sub-specs/api-spec.md
ELSE:
SKIP this_step
</decision_tree>

<file_template>

  <header>
    # API Specification

    This is the API specification for the spec detailed in @.blueprint-oss/specs/current/[PRIORITY-IN-SPEC-QUEUE]-spec-name-YYYY-MM-DD//spec.md

  </header>
</file_template>

<api_sections>
<routes> - HTTP method - endpoint path - parameters - response format
</routes>
<controllers> - action names - business logic - error handling
</controllers>
<purpose> - endpoint rationale - integration with features
</purpose>
</api_sections>

<endpoint_template>

## Endpoints

### [HTTP_METHOD] [ENDPOINT_PATH]

**Purpose:** [DESCRIPTION]
**Parameters:** [LIST]
**Response:** [FORMAT]
**Errors:** [POSSIBLE_ERRORS]
</endpoint_template>

</step>

<step number="11" subagent="project-manager" name="roadmap_update">

### Step 11: Update Roadmap with New Spec

Use the project-manager subagent to update @.blueprint-oss/product/roadmap.md by adding the newly created spec as a roadmap item if it represents a new feature or enhancement.

<conditional_execution>
<preliminary_check>
EVALUATE: Does this spec represent a roadmap-worthy feature?
IF NO (bug fix, minor enhancement, internal refactor):
SKIP this entire step
PROCEED to end
IF YES (new feature, major enhancement, user-facing improvement):
CONTINUE with roadmap update
</preliminary_check>
</conditional_execution>

<roadmap_criteria>
<add_when>
- spec introduces new user-facing functionality
- spec represents significant feature enhancement
- spec aligns with product goals and mission
</add_when>
<skip_when>
- minor bug fixes
- internal code refactoring
- small technical improvements
</skip_when>
</roadmap_criteria>

<instructions>
ACTION: Use project-manager subagent
REQUEST: "Update roadmap with new spec:
          - Read @.blueprint-oss/product/roadmap.md
          - Add unchecked [ ] item for this spec if it's a roadmap-worthy feature
          - Use format: [ ] [SPEC_NAME] - [ONE_SENTENCE_DESCRIPTION]
          - Place in appropriate priority section"
WAIT: For roadmap update completion
</instructions>

<roadmap_item_format>
[ ] [SPEC_NAME] - [ONE_SENTENCE_DESCRIPTION_FROM_OVERVIEW]
</roadmap_item_format>

</step>

<step number="12" subagent="backend-researcher|frontend-researcher" name="revise_spec_handoff">

### Step 12: Revise This Spec (Handoff)

Immediately run the revise-spec instruction against the spec created in Steps 5–10, passing the explicit spec folder path so enumeration is not required.

<handoff>
EXECUTE: @.blueprint-oss/instructions/core/revise-spec.md
WITH:
- selected_spec: [SPEC_FOLDER_PATH_CREATED_IN_STEP_5]
</handoff>

<notes>
- Subagent selection:
  - Use `frontend-researcher` if the spec primarily affects UI/UX, components, styling, or client-side behavior.
  - Otherwise use `backend-researcher` (default) for server, API, data, or infrastructure-heavy specs.
- Use the exact folder path created in Step 5 for this run (e.g., `.blueprint-oss/specs/current/...` or `.blueprint-oss/specs/priority/...`).
- If this instruction was executed via a variant that changes the base folder (e.g., priority specs), pass that variant’s actual created path instead.
</notes>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
