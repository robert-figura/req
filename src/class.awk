
### classify

# unicode phrase and word
/^[a-zA-Z\x80-\xff][0-9a-zA-Z\x80-\xff]*$/ {
    set("phrase", $0)
    set("word", $0)
}
/^[a-zA-Z\x80-\xff][0-9a-zA-Z\x80-\xff .,:;'"\-()\n]*$/ {
    set("phrase", $0)
}

# alphanumeric_identifier
/^[_a-zA-Z][_a-zA-Z0-9-]*$/ {
    set("identifier", $0)
}

# number
match($0, /^0x([0-9a-fA-F]+)$/, m) {
    set("hex", tolower(m[1]))
    set("num", "" strtonum("0x" get("hex")))
}
/^[0-9,]+$/ {
    # the string "0" evaluates to true:
    n = "" (0 + gensub(/,/,"","g",$0))
    set("num", n)
    set("decimal", n)
}

# math formula
/^[xyz0-9][-+*/^() xyz0-9.]+$/ && /[-+*/^()]/ {
    set("formula", $0)
}

# date
# 2012-3-17
match($0, /([0-9][0-9][0-9][0-9])[-.,:; ]+(1[012]|0?[1-9])[-.,:; ]+(3[01]|[12][0-9]|0?[1-9])/, m) {
    set("year", m[1])
    set("mon", m[2])
    set("mday", m[3])
}
# 2012, Mar 17 
match($0, /([0-9][0-9][0-9][0-9])[-.,:; ]+([a-zA-Z][a-zA-Z][a-zA-Z])[-.,:; ]+(3[01]|[12][0-9]|0?[1-9])/, m) &&
match("janfebmaraprmayjunjulaugsepoctnovdec", tolower(m[2])) &&
RSTART % 3 == 1 {
    set("year", m[1])
    set("mon", (RSTART+2)/3) # <- thanks for this trick to Ed Morton in comp.lang.awk
    set("mday", m[3])
}
# 17.3.2012
match($0, /(3[01]|[12][0-9]|0?[1-9])[-.,:; ]+(1[012]|0?[1-9])[-.,:; ]+([0-9][0-9][0-9][0-9])/, m) {
    set("mday", m[1])
    set("mon", m[2])
    set("year", m[3])
}
# 17 Mar 2012
match($0, /(3[01]|[12][0-9]|0?[1-9])[-.,:; ]+([a-zA-Z][a-zA-Z][a-zA-Z])[-.,:; ]+([0-9][0-9][0-9][0-9])/, m) &&
match("janfebmaraprmayjunjulaugsepoctnovdec", tolower(m[2])) &&
RSTART % 3 == 1 {
    set("mday", m[1])
    set("mon", (RSTART+2)/3) # <- thanks for this trick to Ed Morton in comp.lang.awk
    set("year", m[3])
}
get("year") && get("mon") && get("mday") {
    set("date", get("year") "-" get("mon") "-" get("mday"))
}

# time
match($0, /([012]?[0-9]):([0-5]?[0-9])(:([0-5]?[0-9]))?/, m) {
    set("hour", m[1])
    set("min", m[2])
    set("sec", m[4])
    set("time", get("hour") ":" get("min") ":" firstOf(get("sec"), "00"))
}

# hostname
match($0, /^(localhost|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)(:[0-9]+)?$/, m) ||
match($0, /^([-a-zA-Z0-9.-]+\.[a-zA-Z]+)(:[0-9]+)?$/, m) {
    set("host", m[1])
    set("hport", m[2])
    set("hostport", $0)
}

# email
match($0, /^<?([^ @]+@([a-zA-Z0-9.-]+))>?$/, m) {
    set("email", m[1])
    set("host", m[2])
    # split_host($0, email) ; if(!host[]) copyArray(email, host)
}

# feed: url handling (rss, atom)
match($0, /^rss:(.*)$/, m) {
    set("rss", m[1])
    if(get("rss") !~ /https?:\/\//)
	set("rss", "http://" get("rss"))
}

/^ftp:\/\// {
    split_url($0, class, "ftp")
    set("host", get("ftp.host"))
}

# http host
/^https?:\/\// {
    split_url($0, class, "http")
    set("host", get("http.host"))
}
get("http.path") {
    set("http.file", file_basename(get("http.path")) preif(".", file_ext(get("http.path"))))
    set("http.dir", file_dirname(get("http.path")))
}
get("http.query") {
    split(get("http.query"), q, "&")
    for(i in q) {
	match(q[i], /^([^=]*)=(.*)$/, m)
	set("http.args." m[1], urldecode(m[2]))
    }
}

# ssh host
match($0, /^ssh:\/\/(([^@:\/ ]*)@)?([^:\/ ]+)(:([0-9]+))?(\/(.*))?$/, m) {
# !get("http.host") && match($0, /^(([^:@\/ ]*)@)?([^:\/ ]+):()()()((\/[^\/]|[^/]).*)?$/, m) {
    set("proto", "ssh")
    set("ssh.user", m[2])
    set("ssh.host", m[3])
    set("host", m[3])
    set("ssh.port", m[5])
    set("ssh.file", m[7])
    set("ssh.url", "ssh://" postif(get("ssh.user"), "@") get("ssh.host") preif(":", get("ssh.port")) get("ssh.file"))
}

# vnc url
match($0, /^vnc:\/\/(([^@:/]*)(:([^@:/]*))?@)?([^:/]*)(:([0-9\.]*)|::([0-9]*))?$/, m) {
    set("vnc.user", m[2])
    set("vnc.pass", m[4])
    set("vnc.host", m[5])
    set("vnc.display", m[8])
    set("vnc.port", m[9])
}

# hostname is an ip
get("host") ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {
    set("ip", get("host"))
}

# extract domain from host
get("host") {
    set("domain", match_domain(get("host")))
}

match($0, /^dvb:\/\/(.*)$/, m) {
    set("dvb", m[1])
}
# convert web address to dvb channel
!get("dvb") && match($0, /tvinfo\.de\/tv-programm\/([\-a-zA-Z0-9]+)/, m) {
    set("dvb", s = tolower(m[1]))
    # local channel names differ, remap those:
    m["wdr"] = "wdrbonn"
    m["srtl"] = "superrtl"
    m["zdfneo"] = "kika"
    m["tele-5"] = "tele5"
    if(m[s])
	set("dvb", m[s])
}
!get("dvb") && inlist(HOME "/.mplayer/channels.conf.ter", $0, 1, ":") {
    set("dvb", tolower($0))
}

# color
match($0, /^#([0-9a-fA-F]{6,6})$/, m) {
    set("color", m[1])
}
