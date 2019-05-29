
# This port file implements a few microformats in pseudo-command
# style, so you can add applications to start to your favorites:

#  pager <cmd>   show <cmd>'s output in pager
#  bg <cmd>      run <cmd> in background
#  xterm <cmd>   run <cmd> in xterm
#  xterm         just run xterm in pwd

# Use it for starting favorites like this:
# $ dmenu < ~/.favorites | req -p start -stdin
# ...or have a look at extra/port/hotkey.awk!

@include "open.awk"

match($0, /^pager (.*)$/, m) {
    set("xterm_title", m[1])
    auto(1); menu(pager(m[1]))
}
match($0, /^bg (.*)$/, m) {
    auto(1); menu(m[1])
}
match($0, /^xterm( +(.*))?( +-e +(.*))$/, m) {
    set("xterm_title", m[4])
    auto(1); menu(xterm(m[4], m[2]))
}
match($0, /^xterm$/, m) {
    auto(1); menu(xterm())
}
