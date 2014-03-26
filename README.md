# git-prompt

Bash prompt for Git

The main file in this project is the ``git-prompt.sh`` file, which is a
bash script that defines a function called ``git_prompt``, which outputs
a small string showing the status of your Git repository, including the
current branch/head, ahead/behind status, and working directory status.

It's used by default to generate a custom bash prompt whenever you're in
a Git-managed directory.

## Installation

1. Copy ``git-prompt.sh`` into your home directory
2. Add ``source ~/git-prompt.sh`` to your ``~/.bashrc`` file (or your
   ``~/.bash_aliases`` file, as your prefer)
3. Run ``source ~/.bashrc``

## Design

The ``git_prompt`` function will return a string showing the current branch
name as well as how ahead/behind it is from its origin (since the last fetch).
It will also show (via asterisk after the branch name) whether the working
directory is dirty or not. Finally, if you are on a detached HEAD, it will
attempt to show the tag, or the SHA-1 if the HEAD is not tagged.

``git_prompt`` will return an empty string if you are not in a Git-managed
directory (i.e. if the 'git status' command would fail).

This function is used by default in the ``PROMPT_COMMAND`` environment
variable, which in turn sets the ``PS1`` environment variable to a value
containing withthe output of ``git_prompt``.  You can edit the version
that comes in ``git-prompt.sh`` to match your preferred prompt format.

## Examples

``[master]``

This means that you are currently on the master branch in this git-managed
directory, that you are neither ahead nor behind from master's origin,
and that you have no changes in your working directory.

``[master*]``

This means that you are currently on the master branch in this git-managed
directory, that you are neither ahead nor behind from master's origin,
and that you do have changes in your working directory that are uncommited.

``[3 -> foo]``

This means that you are currently on the foo branch, it is 3 ahead of its
origin (i.e. you can push it) that there are no changes in the working
directory.

``[bar* -> 2]``

This means that you are currently on the bar branch, it is 2 behind of its
origin (i.e. you can fast-forward it) that there are indeed changes in the
working directory.

``[3 -> foobar* -> 2]``

This means that the foobar branch is 3 commits ahead and 2 commits behind
of its origin (i.e. its diverged), and that there are changes in the
working directory.

``[detached(1.1.3)]``

This means that you are currently in detached HEAD mode, and HEAD points
to tag 1.1.3.

``[detached(1aaf71b)]``

This means that you are currently in detached HEAD mode, and HEAD is at
commit 1aaf71b, which is not tagged.
