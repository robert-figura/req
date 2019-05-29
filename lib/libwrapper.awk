
# render commands

func shell(cmd,    shc) {
    shc = SHELL " -c "
    if(index(shc, cmd) == 1)
	return cmd
    label(word(cmd))
    return shc Q(cmd)
}
func xtermcolors(fg, bg) {
    setChoice("xterm_fg", fg)
    setChoice("xterm_bg", bg)
}
func xterm(cmd, flags,    c) {
    label(cmd ? word(cmd) : "xterm")
    c = HOME "/.req/extra/xterm"
    c = c wrap(" ", flags)
    c = c wrapQ(" -title ", coalesce(get("xterm_title"), get("label")))
    c = c wrapQ(" -fg ", get("xterm_fg"))
    c = c wrapQ(" -bg ", get("xterm_bg"))
    c = c wrap(" -e ", cmd)
    return c
}
func xterm_error(c) {
    return xterm(shell("if ! " c " ; then echo \"exitcode: $?, press ENTER to continue\" ; read _ ; fi"))
}
func pager(cmd) {
    return xterm(shell(cmd " | less"))
}

# menu and ui
func menucolors(fg, bg, selfg, selbg,    s) {
    setChoice("menu_fg", fg)
    setChoice("menu_bg", bg)
    setChoice("menu_sel_fg", selfg)
    setChoice("menu_sel_bg", selbg)
}
func dmenu(    c) {
    c = "grep -v -e '^ #' -e '^ *$' | " # filter comment-only and empty lines
    c = c "dmenu -l 15 "
    if(!get("no_prompt"))
	c = c wrapQ(" -p ", get("menu_prompt"))
    c = c wrapQ(" -fn ", get("menu_font"))
    c = c wrapQ(" -nf ", get("menu_fg"))
    c = c wrapQ(" -nb ", get("menu_bg"))
    c = c wrapQ(" -sf ", get("menu_sel_fg"))
    c = c wrapQ(" -sb ", get("menu_sel_bg"))
    return c
}
func cat(f1, f2, f3) {
    return "cat" wrapQ(" ", expand_tilde(f1)) wrapQ(" ", expand_tilde(f2)) wrapQ(" ", expand_tilde(f3))
}
func tac(f1, f2, f3) {
    return "tac" wrapQ(" ", expand_tilde(f1)) wrapQ(" ", expand_tilde(f2)) wrapQ(" ", expand_tilde(f3))
}
func dispatch(from, args) {
    return "dispatch -f " Q(from) " " args
}
func dispatch_favorites(args) {
    menucolors("#ffffff", "#006699", "#000000", "#ffffff")
    return cat(get("favorites"), get("bookmarks")) " | " dmenu() " | " dispatch("favorites", args " -# -stdin")
}
func dispatch_history(args) {
    menucolors("#ffffff", "#444444", "#000000", "#ff7f00")
    return tac(get("history")) " | uniq | " dmenu() " | " dispatch("history", args " -stdin")
}
func xmessage(msg, buttons) {
    return "xmessage " wrapQ("-buttons ", buttons, " ") Q(msg)
}
func confirm(msg, cmd) {
    return "if " xmessage(msg, "ok:0,cancel:1") " ; then " cmd " ; fi"
}

# media players
func mpv(f, a) {
    return xterm("mpv --pause --title " Q(f) " " Q(f) " " a)
}
func mpv_playlist(u, r,    t, c) {
    label("play all");
    t = tmp_name("playlist")
    c =   "href " wrapQ("-e ", r) " " Q(u) " > " Q(t) " && "
    c = c "mpv --pause --no-ytdl --playlist=" Q(t) " ; "
    c = c "rm -f " Q(t)
    let("xterm_title", "mpv")
    return xterm(shell(c))
}
func mpc_play(path) {
    return shell("mpc clear ; mpc add " Q(path) " ; mpc play")
}

# documents
func man(args) {
    return xterm("man " args)
}
func info(args) {
    return xterm("info " args)
}

# network
func ssh(remote, cmd) {
    label("ssh")
    return "ssh" wrapQ(" -p", get("ssh_port")) " " Q(remote) wrapQ(" ", cmd)
}

# editor
func edit(f) {
    return emacsclient(f, get("line"))
}
func emacsclient(file, line) {
    label("emacs")
    return "emacsclient -n" wrapQ(" +", line) wrapQ(" ", file)
}

# web browser
func browser(url) {
    return req("browser", "-a no_auto 0", url)
}
func surf(u,    c) {
    c = "surf "
    c = c (get("allow_image") ? "-I " : "-i ")
    c = c (get("allow_script") ? "-S " : "-s ")
    c = c (get("allow_plugins") ? "-P " : "-p ")
    c = c "-N " # inspector
    c = c wrapQ("-c ", get("cookie_file"), " ")
    env("http_proxy", get("http_proxy"))
    return c Q(u)
}
func xprop_set(xwin, p, v, t) {
    if(!t)
	t = "8s"
    return "xprop -id " Q(xwin) " -f " Q(p) " " t " -set " Q(p) " " Q(v)
}
func surf_go(xwin, url) {
    let("label", "surf go")
    return xprop_set(xwin, "_SURF_GO", url)
}

# calculators and function plotters
func QQ(s) {
    # quote " and \ using \, and enclose in "
    return "\"" gensub(/([\\"])/, "\\\\\\1", "g", s) "\""
}
func gp(f) {
    label("pari/gp")
    return pager("echo " Q("print(" QQ(f " = ") "); print(" f ")") " | gp -q")
}
func gnuplot(f) {
    label("gnuplot")
    return "gnuplot -e " Q("print " QQ(f) " ; plot " f) " -"
}

# download
func dl(cmd, uri, target) {
    label("dl " word(cmd))
    defChoice("download_filename", file_basename(get("uri_file")))
    return xterm(REQ_DIR "/extra/dl " Q(uri) " " cmd " " Q(uri))
}

func dl_curl(uri,    c) {
    c = "curl"
    c = c " -O"
    c = c " -L"
    c = c wrapQ(" -e ", get("referer"))
    if(get("cookie_file") != "/dev/null")
	c = c wrapQ(" -c ", get("cookie_file"))
    return dl(c, uri)
}
func dl_git(uri) {
    return dl("git clone", uri)
}
func dl_rsync(uri) {
    return dl("rsync", uri)
}
func dl_scp(uri) {
    return dl("scp", uri, ".")
}
func dl_youtube(uri,    c) {
    c = "youtube-dl"
    c = c " --continue"
    c = c " --no-mtime"
    c = c " --no-playlist"
    c = c " --format " Q(get("ytdl_format"))
    c = c wrapQ(" --referer ", get("referer"))
    c = c wrapQ(" --cookies ", get("cookie_file"))
    return dl(c, uri)
}
func dl_mpv(uri) {
    c = "mpv"
    c = c " --stream-dump=" get("download_file")
    return dl(c, uri, get("download_file"))
}

function websearch(url, phrase, post,    m) {
    match(url, /^(https?:\/\/)?(www\.)?([^/]+).*$/, m)
    label(m[3])
    return browser(url urlencode(phrase) post)
}
