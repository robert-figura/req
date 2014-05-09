
# pick a port based on -f / attr.from or a keyword provided as $0

# rationale: configuring other software is nasty, mostly because we
# have to work on many files in different formats to put up a new
# concept.

# One could use port files instead, solely including other port files,
# but it seems a bit of a waste to have that many files. And using
# attr.from is more suggestive when it comes to name these files.

# todo: we could do without by better employing %notation to refer to nested instances' ctx:
@include "ctx.awk"

BEGIN {
    DEFAULT_MENU["menu"] = "default"
    MOUSE_MENU["menu"] = "9menu"
}

function menucolors(fg, bg, selfg, selbg,    s) {
    export("menu_fg", fg)
    export("menu_bg", bg)
    export("menu_sel_fg", selfg)
    export("menu_sel_bg", selbg)
}
# events without input should receive it's event identifier as input # todo: we can do better!
attr["from"] == "wm" && $0 == "title1" {
    menucolors("#ffffff", "#006699", "#ffffff", "#ff7f00")
    run(nest(get("ctx.xprop.wm_name"), "wm_name", MOUSE_MENU))
}
attr["from"] == "wm" && $0 == "title2" {
    run(nest(get("ctx.sel"), "open", MOUSE_MENU))
}
attr["from"] == "wm" && $0 == "title3" {
    menucolors("#ffffff", "#ff7f00", "#000000", "#ffffff")
    run(nest(get("ctx.xwin"), "wm", MOUSE_MENU))
}

attr["from"] == "wm" && $0 == "status1" {
    run("~/.teslawm/menu.sh ~/.teslawm/status3")
}

# this one expects a substring of the mailclient's window in $0 (sorry):
attr["from"] == "mail-incoming" {
    run("wmu_title.sh " Q($0))
}

# we get a file as argument:
attr["from"] == "BROWSER" ||
attr["from"] == "EDITOR" ||
attr["from"] == "TERMINAL" ||
attr["from"] == "irc-user" ||
attr["from"] == "gnome-desktop-menu" {
    run(nest($0, "open", DEFAULT_MENU))
}
attr["from"] == "rox-mime" ||
attr["from"] == "claws-mime" ||
attr["from"] == "mail-browser" ||
attr["from"] == "mail-editor" ||
attr["from"] == "irc-url" ||
attr["from"] == "gnome-desktop" {
    run(nest($0, "open"))
}

# diff client
func aimplode(    r) {
    r = ""
    for(i = 1; i <= NF; ++i)
	r = r " " $i
    return trim(r)
}
attr["from"] == "hg-diff" {
    run(nest(aimplode(), "diff", DEFAULT_MENU))
}

# download events:
attr["from"] == "download-prepare" {
    # nothing yet
}
attr["from"] == "download-waiting" {
    # nothing yet
}
attr["from"] == "download-success" {
    history(get("download_file"))
    # run(nest(get("download_file"), "open"))
}
REQ_VERBOSE && attr["from"] == "download-success" {
    print "\nSUCCESS: download finished"
    print "url: " attr["download_url"]
    print "file: " attr["download_file"]
    printf("%s", "hit [ENTER] to continue: ")
    system("read")
}
attr["from"] == "download-error" {
    print "\nERROR: download failed!"
    print "reason: " attr["download_error"]
    print "exitcode: " attr["exitcode"]
    print "url: " attr["download_url"]
    print "debug: " $0
    printf("%s", "hit [ENTER] to continue: ")
    system("read")
}

func umount_menu(    f, s, l, m) {
    f = "/proc/mounts"
    s = ""
    while((getline l < f) > 0) {
	split(l, m)
	if(m[2] ~ /^\/(|boot|dev|proc|run|sys|tmp)$/ || m[2] ~ /^\/(dev|var|sys)/)
	    continue
	s = s "\n" m[2]
    }
    close(f)
    c = btick(nest(s, "menu"))
    if(c)
	runHook(nest(c, "umount"))
}
attr["from"] == "umount-menu" {
    run("@umount_menu")
}
