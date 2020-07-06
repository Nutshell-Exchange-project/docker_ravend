#!/bin/bash
set -e

if [[ $(echo "$1" | cut -c1) = "-" ]]; then
  echo "$0: assuming arguments for ravend"

  set -- ravend "$@"
fi

if [[ $(echo "$1" | cut -c1) = "-" ]] || [[ "$1" = "ravend" ]]; then
  mkdir -p "$RAVEN_DATA"
  chmod 700 "$RAVEN_DATA"

  echo "$0: setting data directory to $RAVEN_DATA"

  set -- "$@" -datadir="$RAVEN_DATA"
fi

if [[ "$1" = "ravend" ]] || [[ "$1" = "raven-cli" ]] || [[ "$1" = "raven-tx" ]]; then
  echo
  exec "$@"
fi

echo
exec "$@"
