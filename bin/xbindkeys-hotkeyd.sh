#!/bin/bash

# depends on xbindkeys:
# http://hocwp.free.fr/xbindkeys/xbindkeys.html

verbose=""
if test ".$1" = ".-v" ; then
  verbose="1"
fi

function xbindkeysrc {
  # search for e.g. hotkey("alt+a") and print xbindkeysrc
  gawk 'match($0, /hotkey\("([-+A-Za-z0-9]+)"\)/, m) { print "\"echo " m[1] "\"\n  " m[1] }' ~/.req/src/port.hotkey.awk
}

if test -n "$verbose" ; then
  xbindkeysrc |
  tee /dev/stderr |
  xbindkeys -n -f /dev/stdin |
  req -p hotkey -f hotkey -v -stdin
else
  xbindkeysrc |
  xbindkeys -n -f /dev/stdin |
  req -p hotkey -f hotkey -stdin
fi

case "$?" in
  0)
    if test -n $verbose ; then
      echo "$0: quit"
    fi
    ;;
  1)
    # restart
    exec "$0" "$@"
    ;;
  *)
    echo "$0: req returned nonzero exit status: $?"
    ;;
esac
