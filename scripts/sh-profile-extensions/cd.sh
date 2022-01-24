#!/bin/sh
# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

__cdws__ () {
  if git guess-worktree 1>/dev/null 2>&1; then
    __cdws__=`git guess-worktree "${@}"` && cd "${__cdws__:-.}"
  else
    __cdws__=`guess-worktree "${@}"` && cd "${__cdws__:-.}"
  fi

  [ ${?} -eq 0 ] && git branch-show-current
}

__cdc__ () {
  __cdc__=`"${@:-pwd}"` && cd "${__cdc__:-.}" && pwd
}

alias cdw=__cdws__
alias cdc=__cdc__
