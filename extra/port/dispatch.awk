
# While the commandline interface does offer convenient ways to set
# arguments, when you start configuring what should happen whenever
# an application would call an external program, these arguments
# will end up scattered in obscure application settings.

# It is much more convenient to just tag these configurations with a
# call to req -port dispatch, an appropriate -from, and gather the
# actual arguments here, in this file! 

# Actually it's even better to not set up a req commandline like in:

# req -p dispatch -f my-application event:

# It is better to instead use a wrapper script to call req! Maybe just
# call it `dispatch`. Now, if req's commandline api changes in an
# incompatible way, or you'd like to check out other utilities similar
# to req, you can now easily replace that script, and keep your
# application's setups as is!

# There's an example/dispatch implementation for such a script that
# uses some trickery to guess a better default value for the -from
# argument.

BEGIN {
    setArg("no_history", 1)
    setArg("no_auto", 0)
    setArg("auto", 1)
    export("REQ_LEVEL", 0) # avoid bailing on hotkey -> dispatch -> browser -> dispatch -> browser ...
}

# no classification needed, leaving it out improves performance!

# events class, a structured way to define many one-shot ad-hoc formats
match($0, /^event:(.*)$/, m) {
    set("event", get("from") "/" m[1])
}

################################################################

@include "libwrapper.awk"

# menu about 'object in window'
get("event") == "dwm/title-button-1" {
    menu(req("open", "-% -menu", "%xtitle"))
}
# 'clip buffer paste' menu
get("event") == "dwm/title-button-2" {
    menu(req("open", "-%", "%xsel"))
}
# window menu
get("event") == "dwm/status-button-1" {
    menu(req("open", "-%", "%xwin"))
}
# it's nice to have this accessible via mouse control
get("event") == "dwm/status-button-2" {
    menu(dispatch_history())
}

# these are also issued by extra/port/hotkey.awk:
get("from") == "favorites-menu" {
    menu(req("start", "-menu"))
}
get("from") == "favorites" {
    menu(req("start"))
}
get("from") == "history" {
    menu(req("open", "-menu"))
}

# tag standard environment variables, see extra/setup-bash
get("from") == "BROWSER" ||
get("from") == "EDITOR" ||
get("from") == "TERMINAL" {
    menu(req("open"))
}

# surf middle click, see surf-config.h
get("from") == "surf" {
    menu(req("open"))
}

# some debug facility
func alert(msg) {
    system("xmessage " Q(get("port") ": " msg))
}
cid == 1 {
#    alert("no action defined for '" $0 "'!")
}
