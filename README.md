# git-prompt

Bash prompt for Git

The main file in this project is the `git-prompt.sh` file, which is a
bash script that defines a function called `git_prompt`, which outputs
a small string showing the status of your Git repository, including the
current branch/head, ahead/behind status, and working directory status.

## Installation

1. `source ~/path/to/git-prompt.sh` in `~/.bashrc` or `~/.bash_profile`.
2. Add `export PROMPT_COMMAND=...` with `$(git_prompt)` called somewhere
   within an embedded export of `PS1`.

For example:

```
source /path/to/git-prompt/git-prompt.sh
export PROMPT_COMMAND="$PROMPT_COMMAND;"'export PS1="\h:\W \u $(git_prompt) \$"'
```

## Design

The `git_prompt` function will return a string showing the current branch
name as well as how ahead/behind it is from its upstream since the last fetch.
It will also show (via `*` before the branch name) whether the working
directory is modified, and (via `*` after branch name) whether the index
is modified. If you are rebasing or merging, it will indicate it by using
rebase(...) or merge(...) around of the branch/commit name. Finally, if you
are on a detached HEAD, it will attempt to show the tag, branch, path to
closest ancestor, or SHA-1 of the commit.

`git_prompt` will return an empty string if you are not in a Git-managed
directory (i.e. if the 'git status' command would fail). Otherwise, a
bolded & colored string with 1 space on either side will be output.

## Environment Variables

By default, git_prompt will bold & colorize its output (red for
rebase/merge/detached, and green for everything else). To disable this,
set `GITPROMPT_NOCOLOR` to any non-empty value.

By default, untracked files are not shown because of poor performance in
large repositories. To enable it, which will put a '+' to the left of the
branch name if there are any untracked files, set `GITPROMPT_SHOW_UNTRACKED`
to any non-empty value.


## Examples

`<master>`

You are currently on a branch named master, which has no upstream.

`[master]`

You are currently on the master branch, you are neither ahead nor behind
from master's upstream, and you have no changes in neither your working
directory nor index.

`[*master]`

You are currently on the master branch, you are neither ahead nor behind
from master's upstream, and you have changes in your working directory
that are unstaged.

`[master*]`

You are currently on the master branch, you are neither ahead nor behind
from master's upstream, and you have changes staged to be committed.

`[*master*]`

You are currently on the master branch, you are neither ahead nor behind
from master's upstream, and you have changes in your working directory
that are unstaged as well as changes staged to be committed.

`[3 -> master]`

You are currently on the master branch, which is 3 ahead of its upstream
(i.e. you can push it).

`[master -> 2]`

You are currently on the master branch, which is 2 behind of its upstream
(i.e. you can fast-forward it).

`[3 -> master -> 2]`

You are currently on the master branch, which is 3 ahead and 2 behind
of its upstream (i.e. it's diverged).

`[*merge(master)*]`

You are currently merging into the master branch, and you have both
staged changes (e.g. resolved conflicts) and unstaged changes (e.g.
unresolved conflicts).

`<detached(1.1.3)>`

You are currently in detached HEAD mode, and HEAD points to tag 1.1.3.

`<detached(master~1)>`

You are currently in detached HEAD mode, and HEAD points to the first
parent of master.

`<detached(1aaf71b)>`

You are currently in detached HEAD mode, and HEAD points to commit
1aaf71b, which not a descendent of any named head.

`<rebase(1aaf71b)>`

You are currently rebasing, and HEAD points to commit 1aaf71b.
