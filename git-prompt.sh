# Copy this into your ~/.bashrc


# USAGE
#
#   export PROMPT_COMMAND='export PS1="<your existing prompt>$(git_prompt)"'
#
# The git_prompt function will return a string showing the current branch name
# as well as how ahead/behind it is from its origin (since the last fetch).
# It will also show (via asterisk after the branch name) whether the working
# directory is dirty or not. Finally, if you are on a detached HEAD, it will
# attempt to show the tag, or the SHA-1 if the HEAD is not tagged.
#
# git_prompt will return an empty string if you are not in a git-managed
# directory (i.e. if the 'git status' command would fail).
#
#
#
# EXAMPLES
#
#   [master]
#
#    This means that you are currently on the master branch in this git-managed
#    directory, that you are neither ahead nor behind from master's origin,
#    and that you have no changes in your working directory.
#
#   [master*]
#
#    This means that you are currently on the master branch in this git-managed
#    directory, that you are neither ahead nor behind from master's origin,
#    and that you do have changes in your working directory that are uncommited.
#
#   [3 -> foo]
#
#    This means that you are currently on the foo branch, it is 3 ahead of its
#    origin (i.e. you can push it) that there are no changes in the working
#    directory.
#
#   [bar* -> 2]
#
#    This means that you are currently on the bar branch, it is 2 behind of its
#    origin (i.e. you can fast-forward it) that there are indeed changes in the
#    working directory.
#
#   [3 -> foobar* -> 2]
#
#    This means that the foobar branch is 3 commits ahead and 2 commits behind
#    of its origin (i.e. its diverged), and that there are changes in the
#    working directory.
#
#   [detached(1.1.3)]
#
#    This means that you are currently in detached HEAD mode, and HEAD points
#    to tag 1.1.3.
#
#   [detached(1aaf71b)]
#
#    This means that you are currently in detached HEAD mode, and HEAD is at
#    commit 1aaf71b, which is not tagged.
#

function git_prompt_format() {
  if [ "$1" == 0 ]; then
    return
  fi

  echo -n " ["
  if [ "$2" != 0 ]; then
    echo -n "${2} -> "
  fi

  if [ "$1" == "DETACHEDHEAD" ]; then
    echo -n "detached ($(git describe --always --tags HEAD 2> /dev/null))"
  else
    echo -n $1
  fi

  if [ "$4" != 1 ]; then
    echo -n "*"
  fi

  if [ "$3" != 0 ]; then
    echo -n " -> ${3}"
  fi

  echo -n "]"
}

function git_prompt() {
  export GIT_PROMPT_PARAM="$(git status -b --porcelain 2> /dev/null | gawk '
    match($0, /^## HEAD \(no branch\)$/, groups) {
      printf "DETACHEDHEAD 0 0 ";
    }

    match($0, /^## ([^ ]+)$/, groups) {
      printf "%s 0 0 ", groups[1];
    }

    match($0, /^## ([^ ]+)\.\.\.[^ ]*( \[(ahead ([0-9]+)(, )?)?(behind ([0-9]+))?\])?$/, groups) {
      printf "%s %d  %d ", groups[1], (groups[4]"" == "" ? "0" : groups[4]), (groups[7]"" == "" ? "0" : groups[7]);
    }

    END {
      print NR;
    }
  ')"

  if [ $? -eq 0 ]; then
    git_prompt_format $GIT_PROMPT_PARAM
  fi
}

# MODIFY THE BELOW TO ADD $(git_prompt) WHEREVER YOU WANT IN YOUR PS1
# BUT MAKE SURE YOU ARE EXPORTING PS1 USING THE 'PROMPT_COMMAND' ENV VARIABLE
#
# THE BELOW IS SUGGESTED BASED ON CYGWIN'S DEFAULT PS1
#
export PROMPT_COMMAND='export PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]$(git_prompt)\n\$"'

