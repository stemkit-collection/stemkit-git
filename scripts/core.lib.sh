# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

# To use this library, please add the following lines to the end of your
# shell script file:
#       . `type "${0}" | sed 's/^.* //' | xargs dirname`/core.lib.sh
#       start [import=<library>[,<library>]...] "${@}"

# @expects
#   main "${@}" => exit code
#   process_option <option> [ <argument> ] => 0, 2, 3, 4 (see declaration)
#   process_parameters "${@}" => 0: success, otherwise exits with error
#   options_usage => ?: ignored, echo string to stdout
#   extra_usage_info => ?: ignored, echo strings to stdout
#
# @provides
#   parse_command_line "${@}"
#   process_standard_option <option> [ <argument> ]
#   standard_options_usage
#   usage_and_exit <exit-code> [ <error-message> ]
#
#   report_dry_run
#   ensure_dry_run
#   is_dry_run
#   is_explicit_runmode
#   enable_dry_run
#   disable_dry_run
#
#   run <command-line>
#   run_dangerous <command-line>
#   indent_output_from <command-line>
#
#   log <level-label> <message>
#   error <message>
#   warning <message>
#   info <message>
#   details <message>
#   debug <message>
#   output <descriptor> <message>
#
#   contains_item <item> [ <string> ... ]

standard_options_usage () {
  echo '[-x][--help|-h][--force|-f][--dry-run|-n][--quiet|-q][--vebose|-v]'
}

# @returns
#   0: single option -> shift and go on
#   2: explicit end of options (--) -> shift and stop
#   3: implicit end of options -> stop withoug shift
#   4: option with argument -> shift twice and go on
#   *: error -> report and exit with failure
#
process_standard_option () {
  option=${1}
  argument=${2}

  case "${option}" in
    --force | -f )
      V_CORE_RUN_MODE=force
      disable_dry_run
    ;;

    --dry-run | -n )
      V_CORE_RUN_MODE=dryrun
      enable_dry_run
    ;;

    --quiet | -q )
      exec 1>&5 2>&1
    ;;

    --verbose | -v )
      VERBOSE=yes
    ;;

    --help | -h )
      usage_and_exit 0
    ;;

    -x)
      set -xv
    ;;

    -- )
      return 2
    ;;

    --*=* )
      process_option `echo "${option}" | sed 's/=/ /'` || true
    ;;

    -? | --* )
      usage_and_exit 3 'Unsupported option' "${option}"
    ;;

    -* )
      parse_command_line `echo "${option}" | sed 's/-//g;s/./-& /g'`
    ;;

    *)
      return 3
    ;;
  esac
}

parse_command_line () {
  while [ ${#} -ne 0 ]; do
    process_option "${1}" "${2}" && shift && continue

    case ${?} in
      2)
        shift && break
      ;;

      3)
        break
      ;;

      4)
        shift && [ ${#} -ne 0 ] && shift
      ;;

      *)
        error 'Internal problem'
        exit 5
      ;;
    esac
  done

  process_parameters "${@}" || usage_and_exit 2 'Superfluous parameters' "${*}"
}

report_dry_run () {
  is_dry_run || {
    return
  }
  report="Simulation mode (dry-run)"

  is_explicit_runmode || {
    report="${report}, use --force for normal run"
  }

  info "${report}"
}

ensure_dry_run () {
  is_dry_run || {
    info "Switching to simulation mode (dry-run)"
    enable_dry_run
  }
}

is_explicit_runmode () {
  test "${V_CORE_RUN_MODE:+set}" = set
}

is_dry_run () {
  test "${V_CORE_DRYRUN}" = yes
}

enable_dry_run () {
  V_CORE_DRYRUN=yes
  V_CORE_RUN_MARKER='##'
}

disable_dry_run () {
  V_CORE_DRYRUN=no
  V_CORE_RUN_MARKER='=='
}

usage_and_exit () {
  status=${1}
  shift

  [ ${#} != 0 ] && error "${@}"

  usage "`options_usage`"
  invoke_if_function extra_usage_info

  exit "${status}"
}

invoke_if_function () {
  typeset -f "${1}" 1>&5 && "${@}"
}

run () {
  output 6 "${V_CORE_RUN_MARKER} ${@}"
  is_dry_run || "${@}"
}

run_dangerous () {
  output 6 "${V_CORE_RUN_MARKER} ${@}"

  is_dry_run || {
    ${V_CORE_SAFE_RUN:+output 6 "[SAFE-RUN]"} "${@}"
  }
}

indent_output_from () {
  "${@}" 2>&1 6>&1 | sed 's/^/    /'
}

info () {
  log INFO "${@}"
}

warning () {
  log WARNING "${@}"
}

error () {
  log ERROR "${@}"
}

details () {
  [ "${VERBOSE}" = yes ] && log DETAILS "${@}"
}

debug () {
  [ "${DEBUG}" = yes ] && log DEBUG "${@}"
}

log () {
  label=${1}
  shift

  output 2 `make_log_message "${label}" "${script_name}" "${@}"`
}

make_log_message () {
  while [ ${#} != 0 ]; do
    [ ${#} = 1 ] && echo "${1}" || echo "${1}:" && shift
  done
}

usage () {
  output 2 "USAGE: ${script_name} ${@}"
}

output () {
  descriptor=${1}
  shift

  echo "${@}" 1>&"${descriptor}"
}

contains_item() {
  item=${1}
  shift

  for element in "${@}"; do
    [ "${element}" = "${item}" ] && return 0
  done

  return 1
}

convert_input_to_full_path () {
  while read path; do
    full_folder_path `dirname "${path}"` | xargs -I{} echo {}/`basename "${path}"`
  done
}

full_folder_path () {
  (cd "${1}" 2>&5 1>&2 && pwd)
}

full_prog_path () {
  type "${1}" | awk '{print $(NF)}' | convert_input_to_full_path
}

import () {
  for item in "${@}"; do
    item="${script_folder}/${item}.lib.sh"

    [ -f "${item}" ] || {
      error 'No library' "${item}"
      exit 5
    }

    . "${item}"
  done
}

find_in_path () {
  for folder in `echo "${PATH}" | sed 's/:/ /g'`; do
    path=${folder}/${1}

    [ "${path:+set}" = set -a -x "${path}" ] && {
      echo "${path}" | convert_input_to_full_path
    }
  done
}

start () {
  case "${1}" in
    import=* )
      import `echo "${1}" | sed 's/^.*=//;s/[,:]/ /g'`
      shift
    ;;
  esac

  unset V_CORE_RUN_MODE
  enable_dry_run

  main "${@}"
}

exec 5>/dev/null 6>&2

script_full_path=`full_prog_path "${0}"`
script_folder=`dirname "${script_full_path}"`
script_name=`basename "${script_full_path}"`

VERBOSE=no
DEBUG=no

contains_item "${script_name}" ${TRACE} && {
  DEBUG=yes
}

unset V_CORE_SAFE_RUN
contains_item "${script_name}" ${SAFE_RUN} && {
  V_CORE_SAFE_RUN=yes
}
