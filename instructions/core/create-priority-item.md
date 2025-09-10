---
description: Create fast-track priority spec by referencing core create-spec instruction
globs:
alwaysApply: false
version: 2.1
encoding: UTF-8
---

# Create Priority Item Spec

## Overview

Use this instruction to create a priority spec (hotfix, priority feature, or operational task) under `.blueprint-oss/specs/priority` by following the core spec creation workflow.

<pre_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="execute_create_spec">

### Step 1: Execute Core Spec Creation

Follow the complete spec creation workflow from @.blueprint-oss/instructions/core/create-spec.md with the following modification:

**Directory Override**: Create the spec directory under `.blueprint-oss/specs/priority/` instead of `.blueprint-oss/specs/current/`

<path_modification>
- Base path: `.blueprint-oss/specs/priority/`
- Dirname format: `00-{spec-name}-{YYYY-MM-DD}` (priority 00 by default)
- All other steps remain identical to create-spec.md
</path_modification>

</step>

</process_flow>

<post_flight_check>
EXECUTE: @.blueprint-oss/instructions/meta/post-flight.md
</post_flight_check>
