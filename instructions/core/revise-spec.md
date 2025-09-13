---
description: Spec Revision Rules for blueprint
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Spec Revision Rules

## Overview

Analyze and enhance existing specifications by reading current documentation, referenced files, and code touchpoints to ensure comprehensive and accurate spec documentation.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="spec_selection">

### Step 1: Spec Selection

Use the context-fetcher subagent to list available specs and prompt user for selection. Never auto-select - always wait for explicit user choice.

<selection_requirements>
<list_specs>
Display all specs from both .blueprint-oss/specs/priority/ and .blueprint-oss/specs/current/ as numbered lists:
- First list priority specs (if any exist)
- Then list current specs
- Number continuously across both lists
</list_specs>
<user_prompt>"Which spec would you like to revise? Please provide the spec folder name or number from the list above."</user_prompt>
<wait_for>explicit user selection</wait_for>
<validate>confirm spec exists in either priority or current folder before proceeding</validate>
</selection_requirements>

<example_interaction>
Available specs:

Priority specs:
1. 00-critical-security-fix-2025-01-10
2. 01-urgent-performance-issue-2025-01-12

Current specs:
3. 01-user-authentication-2025-01-15
4. 02-payment-processing-2025-01-20
5. 03-notification-system-2025-01-25

Which spec would you like to revise? Please provide the spec folder name or number from the list above.
</example_interaction>

</step>

<step number="2" subagent="context-fetcher" name="read_current_spec">

### Step 2: Read Current Spec Files

Use the context-fetcher subagent to read all files in the selected spec directory to understand current state and structure.

<reading_requirements>
<primary_files> - spec.md: main requirements document - spec-lite.md: summary version
</primary_files>
<conditional_files> - sub-specs/technical-spec.md (if exists) - sub-specs/database-schema.md (if exists) - sub-specs/api-spec.md (if exists) - tasks.md (if exists) - revision-log.md (if exists)
</conditional_files>
</reading_requirements>

<analysis_points>
<objectives>spec goals and purpose</objectives>
<user_stories>defined workflows and scenarios</user_stories>
<scope>in-scope and out-of-scope items</scope>
<deliverables>expected outcomes</deliverables>
<technical>requirements and constraints</technical>
<gaps>missing or incomplete information</gaps>
</analysis_points>

</step>

<step number="3" subagent="context-fetcher" name="read_referenced_files">

### Step 3: Read Referenced Documentation

Use the context-fetcher subagent to read all .md files referenced within the spec using @ notation to gather complete context.

<reference_discovery>
<pattern>@.blueprint-oss/[path]/[file].md</pattern>
<action>READ each referenced file for context</action>
</reference_discovery>

<typical_references> - product/mission.md - product/mission-lite.md - product/tech-stack.md - product/roadmap.md - standards/*.md - other spec cross-references
</typical_references>

<context_extraction> - mission alignment - technical constraints - standards compliance - feature dependencies
</context_extraction>

</step>

<step number="4" subagent="context-fetcher" name="identify_code_touchpoints">

### Step 4: Find and Read Code Touchpoints

Use the context-fetcher subagent to identify and analyze code files that would be affected by or relevant to this spec implementation.

<code_search_approach>
<keyword_extraction>identify key terms from spec for searching</keyword_extraction>
<search_targets> - class and function names - API endpoints - database models - component names - service implementations
</search_targets>
</code_search_approach>

<search_locations> - src/ or app/ - models/ or database/ - controllers/ or handlers/ - services/ or lib/ - components/ or views/ - tests/ or spec/
</search_locations>

<analysis_focus> - interfaces and contracts - existing implementations - integration points - related test files
</analysis_focus>

<touchpoint_tracking> - file_path:line_numbers - current functionality - integration requirements - potential conflicts
</touchpoint_tracking>

</step>

<step number="5" name="verify_objectives">

### Step 5: Verify Main Objectives

Verify that the main objective of the spec is properly addressed and comprehensive.

<verification_areas>
<completeness> - problem fully addressed - user stories actionable - scope clearly defined - edge cases considered
</completeness>
<accuracy> - technical specs match codebase - API patterns consistent - database conventions followed - dependencies identified
</accuracy>
<clarity> - requirements unambiguous - approach specified - criteria measurable - timeline realistic
</clarity>
</verification_areas>

<gap_identification> - missing user scenarios - technical details needed - error handling gaps - performance requirements - security considerations - testing requirements
</gap_identification>

</step>

<step number="6" subagent="file-creator" name="update_spec_content">

### Step 6: Update and Enhance Spec

Use the file-creator subagent to update spec files with additional details, code examples, and clarifications based on analysis.

<spec_enhancements>
<main_spec> - clearer objectives in overview - expanded user stories with workflows - edge cases added to scope - out-of-scope clarifications - specific deliverable metrics - acceptance criteria
</main_spec>
<technical_spec> - implementation approaches - code examples from touchpoints - integration requirements - error handling patterns - performance requirements - security considerations
</technical_spec>
<database_schema> - exact column types and constraints - migration scripts - index specifications - validation rules - sample data
</database_schema>
<api_spec> - complete request/response schemas - authentication details - rate limiting specs - example payloads - error formats
</api_spec>
</spec_enhancements>

<code_example_format>
```language
// Example from: [file_path:line_number]
// Description: [purpose]
[actual code]
```
</code_example_format>

<update_guidelines> - preserve structure - add clear sections - consistent formatting - include timestamps - note significant changes
</update_guidelines>

</step>

<step number="7" subagent="file-creator" name="add_missing_specs">

### Step 7: Create Missing Sub-Specs

Use the file-creator subagent to create any missing sub-spec files that should exist based on the spec requirements.

<conditional_creation>
IF spec_requires_api_changes AND NOT exists(sub-specs/api-spec.md):
CREATE sub-specs/api-spec.md
IF spec_requires_database_changes AND NOT exists(sub-specs/database-schema.md):
CREATE sub-specs/database-schema.md  
IF spec_requires_ui_components AND NOT exists(sub-specs/ui-spec.md):
CREATE sub-specs/ui-spec.md
IF spec_requires_testing_strategy AND NOT exists(sub-specs/test-spec.md):
CREATE sub-specs/test-spec.md
</conditional_creation>

<file_creation_approach>
ACTION: Use file-creator agent templates
INCLUDE: Cross-references to main spec
ADD: Requirements discovered from code analysis
</file_creation_approach>

</step>

<step number="8" subagent="file-creator" name="update_spec_lite">

### Step 8: Update Spec-Lite Summary

Use the file-creator subagent to update spec-lite.md to accurately reflect the revised spec content.

<lite_revision_criteria> - essence of revised spec - updated key objectives - 3-5 sentence limit - main value proposition - critical technical constraints
</lite_revision_criteria>

</step>

<step number="9" subagent="file-creator" name="create_revision_log">

### Step 9: Create Revision Log

Use the file-creator subagent to create or update a revision-log.md file documenting all changes made.

<revision_log_format>
# Spec Revision Log

## [CURRENT_DATE] - Revision [VERSION]

### Changes Made
- [significant changes]
- [added sections/files]
- [updated requirements]
- [new code touchpoints]

### Rationale
[reason for changes]

### Impact  
[implementation effects]

### Reviewer
revise-spec instruction
</revision_log_format>

</step>

<step number="10" name="user_review">

### Step 10: User Review and Approval

Present summary of revisions and request user review of updated spec documentation.

<review_request>
I've completed the spec revision:

**Files Updated:**
- @.blueprint-oss/specs/current/[SPEC_FOLDER]/spec.md - [changes]
- @.blueprint-oss/specs/current/[SPEC_FOLDER]/spec-lite.md - [changes]
- @.blueprint-oss/specs/current/[SPEC_FOLDER]/sub-specs/technical-spec.md - [changes]
[LIST_OTHER_MODIFIED_FILES]

**Files Created:**
[LIST_NEW_FILES_IF_ANY]

**Key Enhancements:**
1. [enhancement_1]
2. [enhancement_2]
3. [enhancement_3]

**Code Touchpoints:**
- [file:lines] - [description]
- [file:lines] - [description]

Please review the revised spec and revision log.

When ready, you can:
- Accept the revisions
- Request additional changes  
- Run /create-tasks to generate updated tasks
</review_request>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>

