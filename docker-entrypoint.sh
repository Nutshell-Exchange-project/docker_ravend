#!/bin/bash
set -e

if [[ $(echo "$1" | cut -c1) = "-" ]]; then
  echo "$0: assuming arguments for ravend"

  set -- ravend "$@"
fi

if [[ $(echo "$1" | cut -c1) = "-" ]] || [[ "$1" = "ravend" ]]; then
  mkdir -p "$RVN_DATA"
  chmod 700 "$RVN_DATA"

  echo "$0: setting data directory to $RVN_DATA"

  set -- "$@" -datadir="$RVN_DATA"
fi

if [[ "$1" = "ravend" ]] || [[ "$1" = "raven-cli" ]] || [[ "$1" = "raven-tx" ]]; then
  echo
  exec "$@"
fi

echo
exec "$@"
