
@include "libstring.awk"
@include "libfile.awk"
@include "libshell.awk"

@include "libns.awk"
@include "libsplit.awk"

# ctx construction
func set(k, v) {
    setCtx(k, v)
}
func setArray(p, a,    i) {
    if("" p)
	p = p "_"
    for(i in a)
	set(p i, a[i])
}
func get(p) {
    return arg(p)
}

BEGIN {
    REQ_DIR = ENVIRON["REQ_DIR"]
    
    readArgs(REQ_DIR "/req.conf")
    readArgs(ENVIRON["REQ_ARG_FILE"])
}
END {
    printCtx()
}

################################################################
# default context constructions

ENVIRON["PWD"] {
    set("wdir", ENVIRON["PWD"])
}

arg("term") {
    set("term", ENVIRON["TERM"])
}

ENVIRON["DISPLAY"] {
    set("display", ENVIRON["DISPLAY"])
    
    s = backtick("xclip -o 2> /dev/null")
    delete a
    split(s, a, "\n")
    if(a[1])
	set("xsel", a[1])
    
    s = backtick("xprop -root _NET_ACTIVE_WINDOW")
    split(s, a)
    xwin = a[5]
}
xwin {
    set("xwin", xwin)
    
    s = backtick("xprop -id " Q(xwin))
    split_xprop(s, m)
    setArray("xprop", m)
}

s = backtick("wpa_cli -i wlan0 status") {
    delete m
    split(s, m, "\n")
    for(i in m)
	if(match(m[i], /^(.*)=(.*)$/, a))
	    set("wlan0_" a[1], a[2])
}

s = trim(backtick("hostname")) {
    set("hostname", s)
}

# xtitle should refer to the 'current object'. We can often do better
# than really taking the window title!
{
    set("xtitle", ctx("xprop_WM_NAME"))
}
ctx("xprop_res_name") == "rox" {
    set("xtitle", ctx("xprop_WM_WINDOW_ROLE"))
    set("wdir", ctx("xprop_WM_WINDOW_ROLE"))
}
ctx("xprop_res_name") == "surf" {
    set("xtitle", ctx("xprop__SURF_URI"))
}
ctx("xprop_res_name") == "xterm" && match(ctx("xprop_WM_NAME"), /([a-z0-9.-]+)@([a-z0-9.-]+):(.*)$/, m) {
    set("xtitle", m[3])
    set("wdir", m[3])
}
ctx("xprop_res_name") == "emacs" {
    set("wdir", file_dirname(ctx("xprop_WM_NAME")))
    set("wfile", ctx("xprop_WM_NAME"))
}
