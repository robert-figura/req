
func hg_cmd(action, flags, dir) {
    if(!("" dir))
	dir = get("hg_root")
    return "hg " action " -R " Q(dir) wrap(" ", flags)
}
func hg(action, flags, dir) {
    label("hg " action)
    return hg_cmd(action, flags, dir)
}
func git(action, dir, args) {
    if(!("" dir))
	dir = get("git_root")
    label("git " action)
    return "git " action " -R " Q(dir) wrap(" ", args)
}

/^changeset: *([0-9]+):([0-9a-f]+)/ {
#    set("hex", m[2])
#    set("bits", 4 * length(m[2]))
}

prefix_in(ctx("wdir"), "\
/home/rfigura/src/ \
/home/rfigura/tmp/ \
") && s = trim(backtick("cd " Q(ctx("wdir")) " ; hg root")) {
    set("hg_root", s)
}
get("file_dirname") && s = trim(backtick("cd " Q(get("file_dirname")) " ; hg root")) {
    set("hg_root", s)
}
get("hg_root") && get("bits") >= 4*7 {
    set("hg_rev", get("hex"))
    set("hg_revset", get("hex"))
}
get("hg_root") && match($0, /([0-9a-fA-F]{7,})::([0-9a-fA-F]{7,})/, m) {
    set("hg_revset", tolower(m[1]) "::" tolower(m[2]))
}
get("hg_root") && get("file_name") && match(s = backtick(hg_cmd("status", Q(get("file_name")))), /^([A-Z?]) (.*)$/, m) {
    set("hg_status", m[1])
}

################################################################

s = get("hg_rev") {
    s = "parents(" s ")::" s
    let("xterm_title", "hg DIFF " get("file_name"))
    auto(1); label("hg diff parent"); menu(pager(hg("diff", wrapQ("-r ", s) wrapQ(" ", get("file_name")))))
}
get("hg_root") {
    menu(hg("view"))
    auto(get("hg_revset"))
    let("xterm_title", "hg log " get("file_name"))
    menu(pager(hg("log",  wrapQ("-r ", get("hg_revset")) wrapQ(" ", get("file_name")))))
    menu(pager(hg("status")))
}
get("hg_status") == "M" || s = get("hg_revset") {
    label("hg diffstat"); menu(pager(hg("diff", wrapQ("-r ", get("hg_revset"))) " | diffstat"))
    menu(pager(hg("diff", wrapQ("-r ", s) wrapQ(" ", get("file_name")))))
}
get("hg_root") && get("file_name") {
    menu(pager(hg("blame", Q(get("file_name")))))
}
get("hg_status") == "?" {
    menu(xterm_error(hg("add", Q(get("file_name")))))
}
get("hg_status") ~ /^[MAR]$/ && get("file_name") {
    menu(xterm_error(hg("forget", Q(get("file_name")))))
}
