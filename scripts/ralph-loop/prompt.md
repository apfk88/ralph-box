# Ralph Agent Instructions

## Your Task

1. Read `scripts/ralph/prd.json`
2. Read `scripts/ralph/progress.txt`
   (check Codebase Patterns first)
3. Check you're on the correct branch
4. Pick highest priority story 
   where `passes: false`
5. Implement that ONE story
6. Run typecheck and tests
7. Update AGENTS.md files with learnings
8. Commit: `feat: [ID] - [Title]`
9. Update prd.json: `passes: true`
10. Append learnings to progress.txt


## Progress.md Format

APPEND to progress.md:

## [Date] - [Story ID]
- What was implemented
- Files changed
- **Learnings:**
  - Patterns discovered
  - Gotchas encountered
---

## AGENTS.MD

Keep AGENT.md up with your learnings to optimise the build/test loop. When you learn something new about how to run/debug the application or examples make sure you update AGENT.md but keep it brief. For example if you run commands multiple times before learning the correct command then that file should be updated.

SUPER IMPORTANT DO NOT IGNORE. DO NOT PLACE STATUS REPORT UPDATES INTO AGENT.md

## Tasks.md

When tasks.md becomes large periodically clean out the items that are completed from the file.

DO NOT IMPLEMENT PLACEHOLDER OR SIMPLE IMPLEMENTATIONS. WE WANT FULL IMPLEMENTATIONS.

## Bugs

For any bugs you notice, it's important to resolve them or document them in tasks.md to be resolved.

## Git

You do not have access to push your changes remotely. When you are done I will review them and push them myself.

## Stop Condition

If ALL stories pass, reply:
<promise>COMPLETE</promise>
