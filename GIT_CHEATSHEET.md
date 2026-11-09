# Git & GitHub CLI (`gh`) Cheatsheet

## Daily Git Workflow

| Command | What It Does |
| :--- | :--- |
| `git status` | Shows modified, staged, or untracked files. |
| `git add .` | Stages all modified and new files for commit. |
| `git commit -m "Message"` | Saves a snapshot of staged changes with a description. |
| `git push` | Uploads local commits to GitHub. |
| `git pull` | Downloads latest changes from GitHub. |
| `git log --oneline --graph --all` | Shows a clean visual tree of your commit and branch history. |

## How to Undo Mistakes

| Mistake | Command | Keeps Your Code Edits? |
| :--- | :--- | :--- |
| Ruined a file before committing | `git restore <file>` | **No** (resets file) |
| Added wrong file with `git add` | `git restore --staged <file>` | **Yes** |
| Typo in last commit message | `git commit --amend -m "Fix"` | **Yes** |
| Undo last local commit | `git reset --soft HEAD~1` | **Yes** |
| Undo a commit already on GitHub | `git revert <commit-id>` | **No** (creates undo commit) |
| Recover a deleted file (committed) | `git restore --source=<commit-id> <file>` | **Yes** (restores file) |

## Most Used `gh` (GitHub CLI) Commands

| Category | Command | What It Does |
| :--- | :--- | :--- |
| **Auth** | `gh auth login` | Connects your terminal to your GitHub account via browser. |
| **Auth** | `gh auth status` | Checks which account is logged in and verifies your token. |
| **Repos** | `gh repo create` | Creates a new GitHub repository from your current folder. |
| **Repos** | `gh repo clone user/repo` | Downloads a repository without typing the full HTTPS URL. |
| **Repos** | `gh repo view --web` | Opens your current repository page in your default web browser. |
| **Repos** | `gh repo list` | Lists all of your personal repositories right in the terminal. |
| **Issues** | `gh issue list` | Displays open issues/to-do items for the current repository. |
| **Issues** | `gh issue create` | Opens an interactive prompt to create a new issue from terminal. |
| **PRs** | `gh pr create` | Creates a Pull Request from your current branch to `main`. |
| **PRs** | `gh pr status` | Shows the status of any Pull Requests you created or need to review. |
