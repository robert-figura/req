
# mostly what port.open.awk.does, but allow executing binaries as well.
# favorites route through here

@include "ctx.awk"
@include "class.awk"
@include "class.file.awk"

# change directory for these
/^(xterm|rox)$/ && get("ctx.file.dirname") {
    cd(get("ctx.file.dirname"))
}

# the following may run without a terminal
match($0, /^(xterm|rox|alsaplayer|emacs|claws-mail|gimp|xchat|nip2|xchat)$/, m) {
    label("in background"); run("exec " get("cmdline") " > /dev/null 2>&1")
}
match($0, /^hgtk (log|commit)$/, m) {
    run(hgtk(m[1], get("ctx.file.dirname")))
}
match($0, /^hgtk (vdiff|blame)$/, m) {
    run(hgtk(m[1], get("ctx.file.dirname"), Q(get("ctx.file.name"))))
}

# informational commands, show in pager:
get("exe") ~ "^(ps|arp|netstat|ifconfig|iwlist|route|netstat|nmap|rss.sh|wpa_cli)$" {
    label("via pager"); run(pager(get("cmdline")))
}
# interactive console commands:
get("exe") ~ "^(su|top|alsamixer)$" {
    label("in xterm"); run(xterm(get("cmdline")))
}

# everything else:
get("exe") {
    label("in xterm"); menu(xterm(get("cmdline")))
    label("in background"); menu(get("cmdline") " > /dev/null 2>&1")
}

@include "port.open.awk"
