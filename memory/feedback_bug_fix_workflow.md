---
name: Bug fix and multi-file change workflow
description: User loses time when Claude explores broadly instead of starting at the specified file/function
type: feedback
---

For bug fixes: start at the file and function the user specifies. Trace from there. Do not modify other files without explaining why first.

For multi-file changes: always produce a numbered plan (files → changes → reused components) and wait for approval before writing any code.

**Why:** 17 bug-fix sessions logged, with "wrong_approach" as the most frequent error type (30 occurrences). Claude often explored extensively before finding the right file. Multi-file sessions that skipped planning led to wrong scope (e.g., taxonomy vs checkbox, new component vs reuse). 1265 Edit + 192 Write tool calls make unplanned changes expensive to revert.

**How to apply:** When user says "bug in [file] around [function]", open that file first. For any change touching more than one file, output a plan and pause.
