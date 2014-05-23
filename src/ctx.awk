
### gather context data

# note: attr aren't available yet! upside is, `req -a ctx.foo=bar` can override this files code:

BEGIN {
    # interactive terminal
    if(attr["term"])
	setCtx("term", ENVIRON["TERM"])

    # x11 display
    if(ENVIRON["DISPLAY"]) {
	setCtx("display", ENVIRON["DISPLAY"])
	# x11 selection
	setCtx("sel", trim(btick("xclip -o")))
	# current x11 win id
	setCtx("xwin", word(btick("xprop -root _NET_ACTIVE_WINDOW"), 5))
	split_xprop(btick("xprop -id " get("ctx.xwin")), ctx, "ctx.xprop")
    }

    # x11 applications
    if(get("ctx.xprop.wm_class_name") == "Emacs") {
	setCtx("app.exe", "emacs")
	f = get("ctx.xprop.wm_name")
	split_file(f, ctx, "ctx.file")
    }
    if(get("ctx.xprop.wm_class_name") == "XTerm" &&
    (match(get("ctx.xprop.wm_name"), /^([^@]*)@([^:]*):(.*)$/, m) ||
     match(get("ctx.xprop.wm_name"), /^()()(.*)$/, m))) {
	setCtx("app.exe", "xterm")
	setCtx("app.user", m[1])
	setCtx("app.host", m[2])
	setCtx("app.dir", m[3])
	split_file(m[3], ctx, "ctx.file")
    }
    if(get("ctx.xprop.wm_class_name") == "Rox" &&
    match(get("ctx.xprop.wm_name"), /^(.*) \+[ST]$/, m)) {
	setCtx("app.exe", "rox")
	f = gensub(/^~\//, HOME "/", 1, m[1])
	split_file(f, ctx, "ctx.file")
    }
    if(get("ctx.xprop.wm_class_name") == "Sonata" &&
    match(get("ctx.xprop.wm_name"), /^(.*)\/([^/]*)$/, m)) {
	setCtx("app.exe", "sonata")
	setCtx("audio_time", m[3])
	setCtx("audio_total", m[4])
	f = "/home/rfigura/mnt/wirsing/home/rfigura/pub/audio/" m[1] "/" m[2]
	split_file(f, ctx, "ctx.file")
    }
    if(get("ctx.xprop.wm_class_name") == "Hgtk" &&
    match(get("ctx.xprop.wm_name"), /^(.*) - (.*)$/, m)) {
	setCtx("app.exe", "hgtk")
	split_file(m[1], ctx, "ctx.file")
    }
    if(get("ctx.xprop.wm_class_name") == "Surf")
	setCtx("app.url", get("ctx.xprop.url"))

    # working directory
    setCtx("wdir", ENVIRON["PWD"])
    if(get("ctx.file.dirname"))
	setCtx("wdir", get("ctx.file.dirname"))

    # current wifi
    split(btick("wpa_cli status"), m, "\n")
    for(i = 1; i <= length(m); ++i)
	if(match(m[i], /^([^=]*)=(.*)$/, a))
	    setCtx("wifi_" a[1], a[2])
}
