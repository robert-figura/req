
# unicode phrase and word
/^[a-zA-Z_\x80-\xff][0-9a-zA-Z_\x80-\xff]*$/ {
    set("phrase", $0)
    set("word", $0)
}
/^[a-zA-Z_\x80-\xff][0-9a-zA-Z_\x80-\xff .,:;'"\-()\n]*$/ {
    set("phrase", $0)
}

# alphanumeric_identifier
/^[_a-zA-Z][_a-zA-Z0-9-]*$/ {
    set("identifier", $0)
}

# numbers
match($0, /([0-9a-fA-F]{2,})/, m) {
    set("hex", tolower(m[1]))
    set("bits", 4 * length(m[1]))
}

get("hex") {
    set("num", "" strtonum("0x" get("hex")))
}
match($0, /([0-9]+)/, m) {
    n = "" (0 + m[1]) # the string "0" evaluates to true
    set("num", n)
    set("int", n)
}
match($0, /([-+0-9][0-9]*[,.]?[0-9]+)/, m) {
    n = "" (0 + gensub(/,/, ".", 1, m[1]))
    set("num", n)
    set("float", n)
}

# arithmetic expression
/^[-+0-9.][-+*/^() 0-9.]+$/ && /[-+*/^()]/ {
    set("arithmetic", $0)
}
# arithmetic function
/^[-+xyz0-9.][-+*/^() xyz0-9.]+$/ && /[-+*/^()]/ && /[xyz]/ {
    set("function", $0)
}

# hex color triplet
match($0, /#([0-9a-fA-F]{6})/, m) {
    set("color", m[1])
}

# date
# 2012-3-17
match($0, /([0-9][0-9][0-9][0-9])[-.,:; ]+(1[012]|0?[1-9])[-.,:; ]+(3[01]|[12][0-9]|0?[1-9])/, m) {
    set("year", 0+m[1])
    set("mon", 0+m[2])
    set("mday", 0+m[3])
}
# 2012, Mar 17 
match($0, /([0-9][0-9][0-9][0-9])[-.,:; ]+([a-zA-Z][a-zA-Z][a-zA-Z])[-.,:; ]+(3[01]|[12][0-9]|0?[1-9])/, m) &&
match("janfebmaraprmayjunjulaugsepoctnovdec", tolower(m[2])) &&
RSTART % 3 == 1 {
    set("year", 0+m[1])
    set("mon", (RSTART+2)/3) # <- thanks for this trick to Ed Morton in comp.lang.awk
    set("mday", 0+m[3])
}
# 17.3.2012
match($0, /(3[01]|[12][0-9]|0?[1-9])[-.,:; ]+(1[012]|0?[1-9])[-.,:; ]+([0-9][0-9][0-9][0-9])/, m) {
    set("mday", 0+m[1])
    set("mon", 0+m[2])
    set("year", 0+m[3])
}
# 17 Mar 2012
match($0, /(3[01]|[12][0-9]|0?[1-9])[-.,:; ]+([a-zA-Z][a-zA-Z][a-zA-Z])[-.,:; ]+([0-9][0-9][0-9][0-9])/, m) &&
match("janfebmaraprmayjunjulaugsepoctnovdec", tolower(m[2])) &&
RSTART % 3 == 1 {
    set("mday", 0+m[1])
    set("mon", (RSTART+2)/3) # <- thanks for this trick to Ed Morton in comp.lang.awk
    set("year", 0+m[3])
}
get("year") && get("mon") && get("mday") {
    set("date", get("year") "-" get("mon") "-" get("mday"))
}

# time
match($0, /([012]?[0-9]):([0-5]?[0-9])(:([0-5]?[0-9]))?/, m) {
    set("hour", m[1])
    set("min", m[2])
    set("sec", m[4])
    set("time", get("hour") ":" get("min") ":" coalesce(get("sec"), "00"))
}

# uri
/^[][%!*'();:@&=+$,/?#A-Za-z0-9_.~-]+$/ && /%[0-9a-fA-F]{2}/ {
    set("urlencoded", $0)
}
func set_uri(m,    u, p) {
    u = join_uri(m)
    setArray("uri", m)
    set("uri", u)
    set("host", m["host"])
    set("host_port", m["port"])
    set("remote", m["remote"])

    p = get("uri_proto")
    if(p == "https")
	p = "http"
    setArray(p, m)
    set(p, u)
}
split_uri($0, m) {
    set_uri(m)
}
get("ssh_path") {
    set("scp", get("ssh_remote") ":" get("ssh_path"))
    is_a["scp"]++
}
get("http_path") {
    set("http_file", file_basename(get("http_path")) wrap(".", file_ext(get("http_path"))))
    set("http_dir", file_dirname(get("http_path")))
}
# http index accessible via mpd
get("mpd_index") && index(get("http"), get("mpd_index")) == 1 {
    set("mpd_path", urldecode(substr(get("http"), 1+length(get("mpd_index")))))
}
# ad-hoc uri format
match($0, /^dvb:\/\/(.*)$/, m) {
    set("dvb", m[1])
}

# email
!get("uri") && match($0, /^<?([^ @]+@([a-zA-Z0-9.-]+))>?$/, m) {
    set("email", m[1])
    set("host", m[2])
    # split_host($0, email) ; if(!host[]) copyArray(email, host)
}

# host or host:port
match($0, /^(localhost|[-a-zA-Z0-9.-]+\.[a-zA-Z]+|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)(:[0-9]+)?$/, m) {
    set("host", m[1])
    set("host_port", m[2])
    set("remote", $0)
}
match(get("host"), /^(localhost|[-a-zA-Z0-9.-]+\.[a-zA-Z]+)(:[0-9]+)?$/, m) {
    set("hostname", m[1])
}
get("hostname") {
    set("domain", match_domain(get("host")))
}
match($0, /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/, m) {
    set("ip4", m[1])
    set("ip", m[1])
}
match($0, /([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2})/, m) {
    set("ip4_subnet", m[1])
    set("subnet", m[1])
}

func match_ip6(s,    i, m, n, r) {
    if(!(s ~ /^[0-9a-fA-F:]{2,39}$/ && s ~ /:/ && s !~ /::.*::/ && s !~ /[0-9a-fA-F]{5}/))
	return ""
    n = split($0, m, ":")
    if(n < 2 || n>8)
	return ""
    f = ""
    for(i = n; i <= 8; ++i)
	f = f ":0000"
    r = ""
    for(i = 1; i <= n; ++i)
	if(m[i] == "") {
	    r = r f
	    f = ":0000"
	}
	else
	    r = r ":" hex16(strtonum("0x" m[i]))
    return substr(r, 2)
}
s = match_ip6($0) {
    set("ip6", s)
    set("ip", s)
    set("host", s)
}
