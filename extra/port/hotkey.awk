
@include "libwrapper.awk"
@include "libhotkey.awk"

# no classification needed, leaving it out improves performance!

BEGIN {
    export("REQ_CTX_FILE", "") # hotkey is a daemon, recursive req instances need to get a fresh ctx
    setArg("no_history", 1)
    setArg("no_auto", 0)
    setArg("filter_uniq", 0) # not a good idea when operating as a service daemon
    setArg("run", "spawn") # nonblocking
}

{
    auto(1) # only one action per hotkey, just start it!
}

# since this is a req port, you could generate menu() items on keypress,
# but it's usually better to either delegate that to a separate port,
# or to create a .favorites style start menu instead.

# restart
hotkey("mod4+F1") {
    restart()
}

# copy selection -> clipboard
hotkey("mod4+c") {
    menu("xclip -o | xclip -selection clipboard -i")
}
# paste clipboard -> selection
hotkey("mod4+v") {
    menu("xclip -selection clipboard -o | xclip -i")
}

# put to sleep
hotkey("XF86PowerOff") {
# to make this work add a line like this to /etc/sudoers:
# rfigura ALL=(root:root) NOPASSWD: NOSETENV: /usr/sbin/pm-suspend ""
    menu("sudo pm-suspend")
}

# audio mixer via coprocess
hotkey("F10") {
    call("amixer", "sset Master toggle")
}
hotkey("F11") {
    call("amixer", "sset Master 2-")
}
hotkey("F12") {
    call("amixer", "sset Master 2+")
}

# menus
hotkey("mod4+s") {
    menu(dispatch_favorites())
}
hotkey("shift+mod4+s") {
    menu(dispatch_favorites("-menu"))
}
hotkey("mod4+d") {
    menu(dispatch_history())
}

# x11 selection menu
hotkey("mod4+a") {
    menu(req("open", "-f hotkey -%", "%xsel"))
}
hotkey("shift+mod4+a") {
    menu(req("open", "-f hotkey -% -menu", "%xsel"))
}

# window menu
hotkey("mod4+m") {
    menu(req("open", "-f hotkey -% -menu", "%xwin"))
}
# window title menu
hotkey("mod4+n") {
    menu(req("open", "-f hotkey -% -menu", "%xtitle"))
}
