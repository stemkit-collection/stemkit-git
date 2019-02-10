# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

# To use this library, please add the following lines to the end of your
# shell script file:
#       . `type "${0}" | sed 's/^.* //' | xargs dirname`/core.lib.sh
#       start import=ws[,<library>]... "${@}"

report_ws_lib_sh_found () {
  debug "ws.lib.sh" "${script_full_path}" "${*}"
}

ensure_git_workspace () {
  root=`git ws` && cd "${root}" || {
    error "Not a git workspace" "`pwd`"
    exit 2
  }
}

branch_as_path () {
  echo "${1}" | sed 's#[/.]\{1,\}#/#g'
}

branches_with_worktrees () {
  git worktree list | {
    sed -n 's/^\([^ ]*\).*\[\(.*\)\]$/\2 \1/p'
  }
}

branches_without_worktrees () {
  branches_with_worktrees | awk '{print $1}'
}

worktrees_without_branches () {
  branches_with_worktrees | awk '{print $2}'
}

branch_to_worktree () {
  branches_with_worktrees | awk -v b="${1}" '$1 == b {print $2; exit}'
}

worktrees_for_branches () {
  branches_with_worktrees | awk -v input="${*}" '
    BEGIN {
      split(input, array)
      for (position in array)
        branches[array[position]]
    }
    $1 in branches {
      printf "%s => %s\n", $1, $2
    }
  '
}

worktree_to_branch () {
  branches_with_worktrees | awk -v w="${1}" '$2 == w {print $1; exit}'
}
