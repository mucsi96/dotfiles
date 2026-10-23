---
description: Check that a GitHub PR is merged, return to main, and verify a clean working tree
---

Check whether the MR (pull request on GitHub) is merged, then switch back to main and make sure the Git state is clean and up to date.

Use the PR number or URL in $ARGUMENTS if provided. Otherwise identify the PR from the current conversation or current branch using gh. If the intended PR is ambiguous, ask for clarification.

Check the working tree, including untracked files, before switching branches. If there are existing changes, stop and ask how to handle them; do not discard, stash, or commit them automatically.

Use gh to verify that the PR is merged. If it is open or closed without merging, report its state and stop; do not merge it automatically.

Once the PR is confirmed merged and the working tree is clean, switch to main and run git pull --ff-only. If the pull fails or main has diverged, stop and report the blocker without resetting or rebasing.

Verify that main has no staged, unstaged, or untracked changes and that it matches origin/main with no ahead or behind commits. Report the PR URL, its merge status, the current branch, and the final Git state. Do not delete branches unless explicitly requested.
