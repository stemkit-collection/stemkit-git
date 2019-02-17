#!/bin/sh
# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

__cdws__ () {
  git guess-worktree 1>/dev/null 2>&1 && {
    __cdws__=`git guess-worktree "${@}"` && cd "${__cdws__:-.}"
    return ${?}
  }

  __cdws__=`guess-worktree "${@}"` && cd "${__cdws__:-.}"
}

__cdc__ () {
  __cdc__=`"${@:-pwd}"` && cd "${__cdc__:-.}"
}

alias cdw=__cdws__
alias cdc=__cdc__
