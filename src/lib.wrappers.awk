
func firstOf(a1, a2, a3, a4, a5, a6, a7, a8, a9) {
    if(a1) return a1
    if(a2) return a2
    if(a3) return a3
    if(a4) return a4
    if(a5) return a5
    if(a6) return a6
    if(a7) return a7
    if(a8) return a8
    if(a9) return a9
}

# replace regex using a function of match array
func regMap(s, reg, f,    m, r) {
    r = ""
    while(s && match(s, reg, m)) {
	if(!m[0,"length"]) {
	    # avoid endless loop on zero length matches: pass a char
	    r = r substr(s, 1, 1)
	    s = substr(s, 2)
	    continue
	}
	r = r substr(s, 1, m[0,"start"]-1) @f(m)
	s = substr(s, m[0,"start"] + m[0,"length"])
    }
    return r s
}

BEGIN {
    loggerfile = REQ_DIR "/tmp/req.log"
}
func logger(text, file) {
    if(!file)
	file = loggerfile
    print text >> file
    close(file)
}

func split_xprop(str, xprop, idx) {
    if(!idx)
	idx = "xprop"
    if(match(str, /WM_NAME.* = "([^"]*)"/, m))
	xprop[idx, "wm_name"] = m[1]
    if(match(str, /WM_CLASS.* = "([^"]*)", "([^"]*)"/, m)) {
	xprop[idx, "wm_class"] = m[1]
	xprop[idx, "wm_class_name"] = m[2]
    }
    if(match(str, /_NET_WM_PID.* = ([0-9]+)/, m))
	xprop[idx, "net_wm_pid"] = m[1]

    if(match(str, /_SURF_URI\(STRING\) = "([^"]*)"\n/, m))
	xprop[idx, "url"] = m[1]
}

# urls
func match_domain(host) {
    return match(host, /^([-a-zA-Z0-9.]+\.)?([0-9a-zA-Z-]+\.[a-zA-Z-]+)$/, m) ? m[2] : 0
}
func urldecode(text,    m, i, ret) {
    split(text, m, "%")
    ret = m[1]
    for(i = 2; i <= length(m); ++i)
	ret = ret sprintf("%c", strtonum("0x" substr(m[i], 0, 2))) substr(m[i], 3)
    return ret
}
func urlencode(text) {
    return text
}
func match_url(url, m, require_prefix) {
    #   12              34     5 6          7     8 9         a        b  c        d e
    # /^((https?):\/\/)?((USER)(:(PASS))?@)?(HOST)(:(DIGITS))?(\/PATH)?(\?(QUERY))?(#(FRAGMENT))?$/
    return match(url, /^((https?|ftp):\/\/)?(([^:@]+)(:([^@]+))?@)?([^:/]+)(:([0-9]+))?(\/[^?#]*)?(\?([^#]*))?(#(.*))?$/, m) && (!require_prefix || m[2]);
}
func split_url(url, http, idx,    m, p) {
    if(!match_url(url, m))
	return 0
    p = m[2] ? m[2] : "http"
    if(!idx)
	idx = (p == "https") ? "http" : p
    http[idx, "proto"] = p
    http[idx, "user"] = m[4]
    http[idx, "pass"] = m[6]
    http[idx, "host"] = urldecode(m[7])
    http[idx, "domain"] = match_domain(http[idx, "host"])
    http[idx, "port"] = m[9]
    http[idx, "path"] = urldecode(m[10])
    http[idx, "query"] = m[12]
    http[idx, "fragment"] = urldecode(m[14])
    http[idx, "url"] = http[idx, "proto"] "://" postif(http[idx, "user"] preif(":" http[idx, "pass"]), "@") urlencode(http[idx, "host"]) preif(":", http[idx, "port"]) urlencode(http[idx, "path"]) preif("?", http[idx, "query"]) preif("#", urlencode(http[idx, "fragment"]))
}

func inlist(f, token, i, fs,    l, rt) {
    if(!(f in list_cache)) {
	rt = RT
	while((getline l < f) > 0)
	    list_cache[f "_" i "_" word(l, i, fs)]++
	RT = rt
	list_cache[f "_" i]++
	close(f)
    }
    return (f "_" i "_" token) in list_cache
}

func writeMessage(file, attr) {
    verbose("write file: " file)
    for(i in attr)
	if(i != "data")
	    print i "=" attr[i] > file
    print "data=" attr["data"] > file
    close(file)
}

# publish files
func publish(file, dir, url) {
    let("label", "publish")
    return "req -p publish -a publish_dir=" Q(dir) " -a publish_url=" Q(url) " " Q(file)
}

# cmd wrappers:
func xterm(cmd,    m) {
    let("label", word(cmd))
    m[0]; delete m[0]
    copyArray(attr, m)
    m["format"] = "alias"
    return nestcmd(cmd, "xterm")
}
func bash(cmd) {
    return "bash -c " Q(cmd)
}
# todo: replace by xterm(hold()) construct in dependent code:
func xterm_error(cmd) {
    let("label", word(cmd))
    return xterm(Q(REQ_DIR "/bin/hold") " -e " cmd)
}
func surf(url,    f, c) {
    # todo: better arg mechanism
    f = get("surf_flags")
    f = f flag("-c", get("cookie_file"))
    runHook("surf " f " " Q(url))
}
func browser(url) {
    let("label", gensub(/^(https?:\/\/)?([^/]+).*$/, "\\2", 1, url))
    return "@surf " url
}

func man(args) {
    return xterm("man " args)
}
func info(args) {
    return xterm("info " args)
}
func ssh(cmd) {
    return "ssh " Q(postif(get("ssh.user"), "@") get("ssh.host") preif(":", get("ssh.port"))) preif(" ", cmd)
}
func hgtk(action, dir, args) {
    let("label", "hg " action " " word(dir,-1,"/"))
    return "hgtk " action " -R " Q(dir) preif(" ", args)
}
func xsel(s,    c) {
    c = "xclip -i"
    printf "%s", s | c
    close(c)
}

# debug and notify
func notify(msg) {
    if(get("ctx.term"))
	printf("%s", msg)
    else
	xmessage(msg)
}

func xmessage(msg) {
    system("xmessage " Q(msg))
}
BEGIN {
    osd_cat = "exec osd_cat -s 2 -p top -A left --age=3 -d 8 -l 15 -o 20 -c '#44ff44' -f '*-r-*-34-*' -"
}
func xosd(text) {
    if(!text)
	text = get("label")
    print text | osd_cat
}

# bookmarks
func bookmark(s) {
    system("echo " Q(s) " >> " Q(attr["bookmarks"]))
}
func forget(s) {
    tmp = Q(tmpfile("bookmarks.tmp"))
    system("grep -v -x -F " Q(s) " " Q(attr["bookmarks"]) " > " tmp " ; mv " tmp " " Q(attr["bookmarks"]))
}

# history
func history(s) {
    if(!s)
	s = $0
    print s >> attr["history"]
}

# mount tools
func split_mount(    l, m, rt) {
    rt = RT
    while((getline l < "/proc/mounts") > 0) {
	split(l, m)
	if(m[2] == "/" || m[2] ~ /^\/(boot|dev|proc|run|sys|tmp)$/ || m[2] ~ /^\/(dev|sys|var)\//)
	    continue
	setCtx("mount."m[2]".dev", m[1])
	setCtx("mount."m[2]".target", m[2])
	setCtx("mount."m[2]".type", m[3])
	setCtx("mount."m[2]".opts", m[4])
	mounts[m[2]]++
    }
    RT = rt
    close("/proc/mounts")
}
func find_mount(path,    i, ret) {
    ret = ""
    for(i in mounts)
	if(index(path, i) == 1 && length(ret) < length(i))
	    ret = i
    return ret
}
func mount(cmd, t) {
    if(!t)
	t = get("mountpoint")
    if(length(get("ctx.mount."t".target")))
	return
    let("label", "mount " t)
    return cmd " " Q(t)
}
func umount(cmd, t) {
    if(!t)
	t = get("mountpoint")
    if(!length(get("ctx.mount."t".target")))
	return
    let("label", "umount " t)
    return cmd " " Q(t)
}
