#!/bin/sh
# vim: ft=sh: sw=2:
# Author: Gennady Bystritsky (bystr@mac.com)

__stm_add_runtime_script_folders_to_path__ () {
  for d in ~/projects/runtime/*/default/scripts; do
    [ -d "${d}" ] && PATH="${PATH}:${d}"
  done
}

__stm_add_runtime_script_folders_to_path__
