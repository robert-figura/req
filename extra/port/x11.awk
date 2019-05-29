
# classify x11 window id, expensive
get("hex") && s = backtick("xprop -id " Q("0x" get("hex")) " 2> /dev/null") {
    set("xwin", "0x" get("hex"))
    split_xprop(s, m)
    setArray("xprop", m)
}

get("xwin") {
    f = HOME "/Download/shot-" get("xprop_res_name") "-" get("xwin") ".xwd"
    label("screenshot"); menu("xwd -id " Q(get("xwin")) " -nobdrs -out " Q(f) " && " req("open", f))
    menu("xkill -id " get("xwin"))
    menu(pager("xwininfo -id " get("xwin")))
    menu(pager("xprop -id " get("xwin")))
    label("pid (NET_WM_PID)...") menu(req("", get("xprop__NET_WM_PID")))
}
