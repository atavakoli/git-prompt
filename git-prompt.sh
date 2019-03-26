#!/bin/bash

# Source this file into your ~/.bashrc


# USAGE
#
#   export PROMPT_COMMAND='export PS1="<your existing prompt> $(git_prompt) "'
#
# The git_prompt function will return a string showing the current branch name
# as well as how ahead/behind it is from its origin (since the last fetch).
# It will also show (via * before the branch name) whether the working
# directory is modified, and (via * after branch name) whether the index
# is modified. If you are rebasing or merging, it will indicate it by using
# rebase(...) or merge(...) around of the branch/commit name. Finally, if you
# are on a detached HEAD, it will attempt to show a tag, a branch, a path to the
# closest named ancestor, or a SHA-1.
#
# If on a branch with no upstream, or on a detached head, the prompt will use
# angular brackets; otherwise, it will use square brackets.
#
# git_prompt will return an empty string if you are not in a git-managed
# directory (i.e. if the 'git status' command would fail).
#
# ENVIRONMENT
#
# By default, git_prompt will bold & colorize its output (red for
# rebase/merge/detached, and green for everything else). To disable this,
# set GITPROMPT_NOCOLOR to any non-empty value.
#
# By default, untracked files are not shown because of poor performance in
# large repositories. To enable it, which will put a '+' to the left of the
# branch name if there are any untracked files, set GITPROMPT_SHOW_UNTRACKED
# to any non-empty value.
#
# EXAMPLES
#
#   <master>
#
#    You are currently on a branch named master, which has no upstream.
#
#   [master]
#
#    You are currently on the master branch, you are neither ahead nor behind
#    from master's upstream, and you have no changes in neither your working
#    directory nor index.
#
#   [*master]
#
#    You are currently on the master branch, you are neither ahead nor behind
#    from master's upstream, and you have changes in your working directory
#    that are unstaged.
#
#   [master*]
#
#    You are currently on the master branch, you are neither ahead nor behind
#    from master's upstream, and you have changes staged to be committed.
#
#   [*master*]
#
#    You are currently on the master branch, you are neither ahead nor behind
#    from master's upstream, and you have changes in your working directory
#    that are unstaged as well as changes staged to be committed.
#
#   [3 -> master]
#
#    You are currently on the master branch, which is 3 ahead of its upstream
#    (i.e. you can push it).
#
#   [master -> 2]
#
#    You are currently on the master branch, which is 2 behind of its upstream
#    (i.e. you can fast-forward it).
#
#   [3 -> master -> 2]
#
#    You are currently on the master branch, which is 3 ahead and 2 behind
#    of its upstream (i.e. it's diverged).
#
#   [*merge(master)*]
#
#    You are currently merging into the master branch, and you have both
#    staged changes (e.g. resolved conflicts) and unstaged changes (e.g.
#    unresolved conflicts).
#
#   <detached(1.1.3)>
#
#    You are currently in detached HEAD mode, and HEAD points to tag 1.1.3.
#
#   <detached(master~1)>
#
#    You are currently in detached HEAD mode, and HEAD points to the first
#    parent of master.
#
#   <detached(1aaf71b)>
#
#    You are currently in detached HEAD mode, and HEAD points to commit
#    1aaf71b, which not a descendent of any named head.
#
#   <detached(ROOT)>
#
#    You are currently not on any commit (e.g. right after running git init).
#
#   <rebase(1aaf71b)>
#
#    You are currently rebasing, and HEAD points to commit 1aaf71b.
#

function git_prompt() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  local c_red
  local c_green
  local c_bold
  local c_clear

  if [ -z "${GITPROMPT_NOCOLOR}" ]; then
    c_red='\[\e[31m\]'
    c_green='\[\e[32m\]'
    c_bold='\[\e[1m\]'
    c_clear='\[\e[0m\]'
  fi

  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  local gitdir="$(git rev-parse --git-path .)"
  local topleveldir="$(git rev-parse --show-toplevel)"
  local label
  local counts
  local unstaged
  local staged
  local untracked
  local noupstream
  local ahead
  local behind

  if [ -z "$branch" ] || [ $branch == HEAD ]; then
    branchname=$(git describe --all --contains --always HEAD 2>/dev/null)

    if [ -d "$gitdir/rebase-merge" ] || [ -d "$gitdir/rebase-apply" ]; then
      label=rebase
    elif [ -z "$branchname" ]; then
      label=detached
      branchname=ROOT
    else
      label=detached
    fi

    color="$c_red"
    branch="$label($branchname)"
    noupstream=t
  else
    color="$c_green"
    if [ -f "$gitdir/MERGE_HEAD" ]; then
      branch="merge($branch)"
    fi
    read ahead behind < <(git rev-list --count --left-right @{u}... 2>/dev/null)
  fi

  # these currently don't work for the ROOT commit
  if [ "$label" != detached ] || [ "$branchname" != ROOT ]; then
    git ls-files -md --error-unmatch -- "$topleveldir" &>/dev/null && unstaged='*'
    git diff-index --quiet --cached HEAD -- || staged='*'
  fi

  [ -n "$GITPROMPT_SHOW_UNTRACKED" ] \
    && git ls-files --others --directory --no-empty-directory --error-unmatch \
                    -- ':/*' >/dev/null 2>&1 \
    && untracked='+'

  branch="$untracked$unstaged$branch$staged"

  if [ "$ahead$behind" == '' ]; then
    noupstream=t
  else
    if [ -n "$behind" ] && [ $behind -gt 0 ]; then
      branch="$behind -> $branch"
    fi
    if [ -n "$ahead" ] && [ $ahead -gt 0 ]; then
      branch="$branch -> $ahead"
    fi
  fi

  if [ -n "$noupstream" ]; then
    branch="<$branch>"
  else
    branch="[$branch]"
  fi

  echo -n "$c_bold$color$branch$c_clear"
}

# MODIFY THE BELOW TO ADD $(git_prompt) WHEREVER YOU WANT IN YOUR PS1
# BUT MAKE SURE YOU ARE EXPORTING PS1 USING THE 'PROMPT_COMMAND' ENV VARIABLE
#
# FOR EXAMPLE:
#
# export PROMPT_COMMAND="$PROMPT_COMMAND;"'export PS1="\h:\W \u $(git_prompt) \$"'
