---
description: Analyze Current Product & Install blueprint
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Analyze Current Product & Install blueprint

## Overview

Install blueprint into an existing codebase, analyze current product state and progress. Builds on plan-product.md

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="analyze_existing_codebase">

### Step 1: Analyze Existing Codebase

Perform a deep codebase analysis of the current codebase to understand current state before documentation purposes.

<analysis_areas>
<project_structure> - Directory organization - File naming patterns - Module structure - Build configuration
</project_structure>
<technology_stack> - Frameworks in use - Dependencies (package.json, Gemfile, requirements.txt, etc.) - Database systems - Infrastructure configuration
</technology_stack>
<implementation_progress> - Completed features - Work in progress - Authentication/authorization state - API endpoints - Database schema
</implementation_progress>
<code_patterns> - Coding style in use - Naming conventions - File organization patterns - Language-specific patterns
</code_patterns>
</analysis_areas>

<instructions>
  ACTION: Thoroughly analyze the existing codebase
  DOCUMENT: Current technologies, features, and patterns
  IDENTIFY: Architectural decisions already made
  NOTE: Development progress and completed work
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="gather_product_context">

### Step 2: Gather Product Context

Use the context-fetcher subagent to supplement codebase analysis with business context and future plans.

<context_questions>
Based on my analysis of your codebase, I can see you're building [OBSERVED_PRODUCT_TYPE].

To properly set up blueprint, I need to understand:

1. **Product Vision**: What problem does this solve? Who are the target users?

2. **Current State**: Are there features I should know about that aren't obvious from the code?

3. **Roadmap**: What features are planned next? Any major refactoring planned?

4. **Team Preferences**: Any coding standards or practices the team follows that I should capture?
   </context_questions>

<instructions>
  ACTION: Ask user for product context
  COMBINE: Merge user input with codebase analysis
  PREPARE: Information for plan-product.md execution
</instructions>

</step>

<step number="3" name="execute_plan_product">

### Step 3: Execute Plan-Product with Context

Execute our standard flow for installing blueprint in existing products

<execution_parameters>
<main_idea>[DERIVED_FROM_ANALYSIS_AND_USER_INPUT]</main_idea>
<key_features>[IDENTIFIED_IMPLEMENTED_AND_PLANNED_FEATURES]</key_features>
<target_users>[FROM_USER_CONTEXT]</target_users>
<tech_stack>[DETECTED_FROM_CODEBASE]</tech_stack>
</execution_parameters>

<execution_prompt>
@.blueprint-oss/instructions/core/plan-product.md

I'm installing blueprint into an existing product. Here's what I've gathered:

**Main Idea**: [SUMMARY_FROM_ANALYSIS_AND_CONTEXT]

**Key Features**:

- Already Implemented: [LIST_FROM_ANALYSIS]
- Planned: [LIST_FROM_USER]

**Target Users**: [FROM_USER_RESPONSE]

**Tech Stack**: [DETECTED_STACK_WITH_VERSIONS]
</execution_prompt>

<instructions>
  ACTION: Execute plan-product.md with gathered information
  PROVIDE: All context as structured input
  ALLOW: plan-product.md to create .blueprint-oss/product/ structure
</instructions>

</step>

<step number="4" name="customize_generated_files">

### Step 4: Customize Generated Documentation

Refine the generated documentation to ensure accuracy for the existing product by updating roadmap, tech stack, and decisions based on actual implementation.

<customization_tasks>
<roadmap_adjustment> - Mark completed features as done - Move implemented items to "Phase 0: Already Completed" - Adjust future phases based on actual progress
</roadmap_adjustment>
<tech_stack_verification> - Verify detected versions are correct - Add any missing infrastructure details - Document actual deployment setup
</tech_stack_verification>
</customization_tasks>

<roadmap_template>

## Phase 0: Already Completed

The following features have been implemented:

- [x] [FEATURE_1] - [DESCRIPTION_FROM_CODE]
- [x] [FEATURE_2] - [DESCRIPTION_FROM_CODE]
- [x] [FEATURE_3] - [DESCRIPTION_FROM_CODE]

## Phase 1: Current Development

- [ ] [IN_PROGRESS_FEATURE] - [DESCRIPTION]

[CONTINUE_WITH_STANDARD_PHASES]
</roadmap_template>

</step>

<step number="5" subagent="file-creator" name="generate_project_standards">

### Step 5: Generate Project-Specific Standards

Analyze the codebase to extract and document project-specific coding standards, patterns, and best practices.

<analysis_targets>
<code_style_analysis>

- Naming conventions (variables, functions, classes, files)
- Indentation and formatting patterns
- Comment styles and documentation patterns
- Import/export organization
- File structure patterns
  </code_style_analysis>
  <best_practices_analysis>
- Error handling patterns
- State management approaches
- API design patterns
- Security practices
- Performance optimizations
  </best_practices_analysis>
  <language_specific_patterns>
- Language idioms in use
- Framework-specific patterns
- Library usage patterns
- Type system usage (if applicable)
- Async/await patterns
  </language_specific_patterns>
  </analysis_targets>

<standards_generation>
ACTION: Create .blueprint-oss/standards/ directory structure
FILES_TO_CREATE: - .blueprint-oss/standards/best-practices.md - .blueprint-oss/standards/tech-stack.md - .blueprint-oss/standards/code-style/[language]-style.md (e.g., typescript-style.md, rust-style.md)
IMPORTANT: The file named "language-style.md" is just an example placeholder and should be removed after creating actual language-specific style files
</standards_generation>

<language_style_template>

# [LANGUAGE] Style Guide

## Project-Specific [LANGUAGE] Patterns

Based on analysis of the codebase, these are the established [LANGUAGE] patterns:

### Naming Conventions

- **Variables**: [DETECTED_PATTERN] (e.g., camelCase, snake_case)
- **Functions**: [DETECTED_PATTERN]
- **Classes**: [DETECTED_PATTERN]
- **Files**: [DETECTED_PATTERN]
- **Constants**: [DETECTED_PATTERN]

### [LANGUAGE]-Specific Patterns

[DETECTED_LANGUAGE_IDIOMS]

### File Organization

[DETECTED_FILE_STRUCTURE_PATTERNS]

### Import/Module Organization

[DETECTED_IMPORT_PATTERNS]

### Formatting

- **Indentation**: [SPACES/TABS] with [SIZE]
- **Line Length**: [OBSERVED_MAX]
- **Quote Style**: [SINGLE/DOUBLE] (if applicable)
- **Semicolons**: [USAGE_PATTERN] (if applicable)

### Comments and Documentation

[DETECTED_COMMENT_PATTERNS]

### Framework-Specific Patterns (if applicable)

[DETECTED_FRAMEWORK_PATTERNS]
</language_style_template>

<best_practices_template>

# Project Best Practices

## Established Patterns

### Error Handling

[DETECTED_ERROR_PATTERNS_WITH_EXAMPLES]

### State Management

[DETECTED_STATE_PATTERNS]

### API Design

[DETECTED_API_PATTERNS]

### Security

[DETECTED_SECURITY_PRACTICES]
</best_practices_template>

<instructions>
  ACTION: Analyze codebase for patterns
  EXTRACT: Actual patterns from real code
  DOCUMENT: Create standards files based on observations
  INCLUDE: Code examples from the project
  AVOID: Generic standards - must be project-specific
</instructions>

</step>

<step number="6" name="final_verification">

### Step 6: Final Verification and Summary

Verify installation completeness and provide clear next steps for the user to start using blueprint with their existing codebase.

<verification_checklist>

- [ ] .blueprint-oss/product/ directory created
- [ ] .blueprint-oss/standards/ directory created with project-specific standards
- [ ] All product documentation reflects actual codebase
- [ ] Roadmap shows completed and planned features accurately
- [ ] Tech stack matches installed dependencies
- [ ] Code style standards extracted from actual code
- [ ] Best practices documented from observed patterns
      </verification_checklist>

<summary_template>

## ✅ blueprint Successfully Installed

I've analyzed your [PRODUCT_TYPE] codebase and set up blueprint with documentation that reflects your actual implementation.

### What I Found

- **Tech Stack**: [SUMMARY_OF_DETECTED_STACK]
- **Completed Features**: [COUNT] features already implemented
- **Code Style**: [DETECTED_PATTERNS]
- **Current Phase**: [IDENTIFIED_DEVELOPMENT_STAGE]

### What Was Created

- ✓ Product documentation in `.blueprint-oss/product/`
- ✓ Project-specific standards in `.blueprint-oss/standards/`
- ✓ Roadmap with completed work in Phase 0
- ✓ Tech stack reflecting actual dependencies
- ✓ Code style guide based on your patterns
- ✓ Best practices extracted from your code

### Cleanup Required

- ✗ Remove `.blueprint-oss/standards/code-style/language-style.md` if it exists (it's just an example placeholder)
- ✓ Keep actual language-specific style files (e.g., typescript-style.md, rust-style.md)

Your codebase is now blueprint-enabled! 🚀
</summary_template>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
