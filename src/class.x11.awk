
# x11 window id
get("hex") && (s = btick("xprop -id " Q("0x" get("hex")))) {
    set("xwin", "0x" get("hex"))
    split_xprop(s, class, "xprop")
}
