
# x11 window id
get("hex") && (s = btick("xprop -id " Q("0x" get("hex")))) {
    set("xwin", "0x" get("hex"))
    split_xprop(s, class, "xprop")
}

get("xprop.wm_class_name") == "Emacs" &&
(s = file_mimetype(get("xprop.wm_name"))) {
    set("file", get("xprop.wm_name"))
    set("mimetype", s)
}
get("xprop.wm_class_name") == "XTerm" &&
match(get("xprop.wm_name"), /^([^@]*)@([^:]*):(.*)$/, m) {
    set("user", m[1])
    set("host", m[2])
    set("file", m[3])
    set("mimetype", "inode/directory")
}
get("xprop.wm_class_name") == "Rox" &&
match(get("xprop.wm_name"), /^(.*) \+S?T?$/, m) {
    set("directory", gensub(/^~\//, HOME "/", 1, m[1]))
}
get("xprop.wm_class_name") == "Sonata" &&
match(get("xprop.wm_name"), /^(.*)\/([^/]*)$/, m) &&
(s = file_mimetype(f = "~/mnt/ssh/rfigura@wirsing/home/rfigura/pub/audio/" m[1] "/" m[2])) {
    set("file", f)
    set("mimetype", s)
    set("audio_time", m[3])
    set("audio_total", m[4])
}
get("xprop.wm_class_name") == "Hgtk" &&
match(get("xprop.wm_name"), /^(.*) - (.*)$/, m) {
    set("file", m[1])
    set("mimetype", "inode/directory")
}
get("xprop.wm_class_name") == "Surf" {
    set("http.url", get("xprop.url"))
}
