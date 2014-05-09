
# paste, current object, open history or bookmarks
# for favorites see port.start.awk

@include "ctx.awk"
@include "class.awk"
@include "class.file.awk"
@include "class.pid.awk"

get("http.host") == "localhost" &&
match(get("http.path"), /~rfigura\/(.*)$/, m) &&
(t = file_mimetype(f = "/home/rfigura/www/" m[1])) {
    set("file.mimetype", t)
    set("file.name", f)
}

get("dvb") {
    run("dvb " Q(get("dvb")))
}

@include "port.http.awk"
@include "port.file.awk"

get("hex") {
    # todo: review wether prefixing here is the right thing to do:
    run(nest("0x" get("hex"), "wm"))
}

get("rss") {
    label("rss"); run(pager("rss.sh " Q(get("rss"))))
    label("surf"); run(browser(get("rss")))
}

# ssh hosts
get("ssh.host") {
    label("xterm ssh"); run(xterm(ssh()))
}

get("ssh.localfile") {
    label("nest localfile"); run(nest(get("ssh.localfile")))
}
get("ssh.localdir") {
    label("nest localdir"); run(nest(get("ssh.localfile")))
}

get("vnc.host") {
    run("vncviewer " Q(get("vnc.host") preif("::", get("vnc.port"))) " < /dev/null")
}

# man pages
get("exe") {
    menu(man(get("exe")))
}
match($0, /^([A-Za-z0-9_-]+) ?(\[[^\]]+\] )?\(([0-9]+)\)/, m) {
    run(man(Q(m[3]) " " Q(m[1])))
}
# info pages
match($0, /^"?(\([a-zA-Z0-9_-]+\))(([^"]*)")?/, m) {
    run(info(Q(m[1]m[3])))
}

# sql statement via mysql test db
func mysql(s) {
    s = collapse(s)
    s = gensub(/\n/, " ", "g", s)
    runHook(pager("mysql test -e " Q(s)))
}
/^(SELECT|INSERT|UPDATE|DELETE)/ {
    label("mysql"); menu("@mysql " $0)
}

get("email") {
    label("email"); run("claws-mail --compose "Q(get("email")))
    label("mid.groups.google"); menu(browser("http://groups.google.com/groups/search?as_umsgid=" get("email")))
}

@include "port.pid.awk"
@include "port.calc.awk"
@include "port.search.awk"
@include "port.info.awk"

# todo: shouldn't we include port.download.awk instead?:
get("ftp.url") {
    label("download..."); menu(nest(get("ftp.url"), "download"))
}
get("http.url") {
    label("download..."); menu(nest(get("http.url"), "download"))
}

get("hport") {
    label("telnet"); menu("telnet " Q(get("host")) " " Q(get("hport")))
}

@include "port.default.awk"
@include "port.history.awk"
