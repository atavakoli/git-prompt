#!/bin/bash

# Source this file into your ~/.bashrc


# USAGE
#
#   export PROMPT_COMMAND='export PS1="<your existing prompt>$(git_prompt)"'
#
# The git_prompt function will return a string showing the current branch name
# as well as how ahead/behind it is from its origin (since the last fetch).
# It will also show (via * before the branch name) whether the working
# directory is modified, and (via * after branch name) whether the index
# is modified. Finally, if you are on a detached HEAD, it will attempt to
# to show a tag, a branch, a path to the closest named ancestor, or a SHA-1.
#
# If on a branch with no upstream, or on a detached head, the prompt will use
# angular brackets; otherwise, it will use square brackets.
#
# git_prompt will return an empty string if you are not in a git-managed
# directory (i.e. if the 'git status' command would fail).
#
#
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
#    You are currently in detached HEAD mode, and HEAD points tocommit
#    1aaf71b, which not a descendent of any named head.
#

function git_prompt() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  local c_red='\[\e[31m\]'
  local c_green='\[\e[32m\]'
  local c_bold='\[\e[1m\]'
  local c_clear='\[\e[0m\]'

  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  local counts
  local unstaged
  local staged

  if [ -z "$branch" -o "$branch" == "HEAD" ]; then
    color="$c_red"
    branch="<detached($(git describe --all --contains --always HEAD))>"
  else
    color="$c_green"

    git diff --no-ext-diff --quiet || unstaged='*'
    git diff --no-ext-diff --quiet --staged || staged='*'

    branch="$unstaged$branch$staged"

    read ahead behind < <(git rev-list --count --left-right @{u}... 2>/dev/null)

    if [ "$ahead$behind" == '' ]; then
      branch="<$branch>"
    else
      if [ -n "$behind" ] && [ $behind -gt 0 ]; then
        branch="$behind -> $branch"
      fi
      if [ -n "$ahead" ] && [ $ahead -gt 0 ]; then
        branch="$branch -> $ahead"
      fi

      branch="[$branch]"
    fi
  fi

  echo -n " $c_bold$color$branch$c_clear "
}

# MODIFY THE BELOW TO ADD $(git_prompt) WHEREVER YOU WANT IN YOUR PS1
# BUT MAKE SURE YOU ARE EXPORTING PS1 USING THE 'PROMPT_COMMAND' ENV VARIABLE
#
# FOR EXAMPLE:
#
# export PROMPT_COMMAND="$PROMPT_COMMAND;"'export PS1="\h:\W \u$(git_prompt)\$"'
