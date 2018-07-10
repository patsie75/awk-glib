#!/usr/bin/env bash

mawkbin="$(which mawk)"
gawkbin="$(which gawk)"

if [ "$1" == "mawk" -a -n "$mawkbin" ]; then
  awkbin="$mawkbin"
elif [ "$1" == "gawk" -a -n "$gawkbin" ]; then
  awkbin="$gawkbin --posix"
elif [ -n "$mawkbin" ]; then
  awkbin="$mawkbin"
elif [ -n "$gawkbin" ]; then
  awkbin="$gawkbin --posix"
fi

LC_ALL=C ${awkbin} -f lib/glib.awk -f examples/animate.awk $@
