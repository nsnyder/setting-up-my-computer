#!/usr/bin/env bash

main() {
  case "$1" in
    ip)
      $IP_ADDRESS
      ;;
  esac
}

main $@
