# Ralph Agent Instructions

## Your Task
Your task is to complete tasks in tasks.md using parrallel subagents.

0. Read `scripts/ralph/tasks.md`

0. Read `scripts/ralph/progress.md`(check Codebase Patterns first)

0. Read AGENTS.md 

0. Check you're on the correct branch

1. Study tasks.md and choose the most important 10 things where `passes:false`. Before making changes search codebase (don't assume not implemented) using subagents.

2. Implement ONE story per subagent. That subagent should only implement that one story. You may use up to 100 parrallel subagents for all operations but only 1 subagent for build/tests.

3. After implementing functionality or resolving problems, run typechecks, builds, and tests for that unit of code that was improved. If functionality is missing then it's your job to add it as per the application specifications. Think hard.

4. Update AGENTS.md file with learnings

5. Append learnings to progress.txt

6. Update tasks.md: `Passes: true`

7. Commit: `feat: [ID] - [Title]`

8. Repeat and choose more tasks.

## Progress.md Format

APPEND to progress.md:

## [Date] - [Story ID]
- What was implemented
- Files changed
- **Learnings:**
  - Patterns discovered
  - Gotchas encountered
---

## AGENTS.md

Keep AGENT.md up with your learnings to optimise the build/test loop using a subagent. When you learn something new about how to run/debug the application or examples make sure you update AGENT.md using a subagent but keep it brief. For example if you run commands multiple times before learning the correct command then that file should be updated.

SUPER IMPORTANT DO NOT IGNORE. DO NOT PLACE STATUS REPORT UPDATES INTO AGENT.md

## Tasks.md

ALWAYS KEEP tasks.md up to do date with your learnings using a subagent. Especially after wrapping up/finishing your turn.

When tasks.md becomes large periodically clean out the items that are completed from the file using a subagent.

DO NOT IMPLEMENT PLACEHOLDER OR SIMPLE IMPLEMENTATIONS. WE WANT FULL IMPLEMENTATIONS.

## Bugs

For any bugs you notice, it's important to resolve them or document them in tasks.md to be resolved using a subagent.

## Git

You do not have access to push your changes remotely. When you are done I will review them and push them myself.

## Stop Condition

If ALL stories pass, reply:
<promise>COMPLETE</promise>
