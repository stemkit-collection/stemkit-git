# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

# To use this library, please add the following lines to the end of your
# shell script file:
#       . `type "${0}" | sed 's/^.* //' | xargs dirname`/core.lib.sh
#       start import=git[,<library>]... "${@}"

report_git_lib_sh_found () {
  debug "git.lib.sh" "${script_full_path}" "${*}"
}

setup_git_environment () {
  # This is a work-around for a weird problem on a newer git versions
  # that set GIT_DIR, which causes "git ws" work as "git top" when
  # executed deep inside a custom workspace.
  #
  unset GIT_DIR

  git stm-aliases-available 2>&5 || {
    git () {
      __trace__ ${__git_exec__} "${SK_GIT_REAL:?}" -c include.path="${SK_GIT_LOADER:?}" "${@}"
    }

    unset __git_ws_root__

    ensure_git_real
    ensure_git_loader
  }
}

__trace__() {
  [ "${DEBUG}" = yes ] && output 6 == "${@}"
  "${@}"
}

from_ws_root () {
  for item in "${@}"; do
    echo "${__git_ws_root__}/${item}"
  done
}

figure_ws_root_unless_set () {
  [ "${1:+set}" = set ] && return 1
  [ "${__git_ws_root__:+set}" = set ] && return 0

  for marker in ${script_folder}/{.,..,../..,../../..}/.git; do
    [ -d "${marker}" ] && {
      __git_ws_root__=`echo "${marker}" | convert_input_to_full_path | xargs dirname`
      return 0
    }
  done

  error 'No workspace root'
  exit 2
}

ensure_git_real () {
  figure_ws_root_unless_set "${SK_GIT_REAL}" || return
  hook=`from_ws_root scripts/hooks/git`

  for item in `find_in_path git`; do
    [ "${item}" != "${hook}" ] && {
      SK_GIT_REAL=${item}
      git=${hook}

      export SK_GIT_REAL git
      return
    }

    shift
  done

  error 'No real git in PATH'
  exit 2
}

ensure_git_loader () {
  figure_ws_root_unless_set "${SK_GIT_LOADER}" || return
  aliases=`from_ws_root config/dot-gitloader`

  [ -f "${aliases}" ] && {
    SK_GIT_LOADER=${aliases} export SK_GIT_LOADER
    return
  }

  error "Missing git aliases" "${aliases:-'???'}"
  exit 3
}
