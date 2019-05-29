
func split_file(f, r,   m) {
    delete r
    if(!(m = file_mimetype(f)))
	return 0
    r["mimetype"] = m
    if(m == "inode/directory") {
	r["directory"] = f
	r["dirname"] = f
	return 1
    }
    r["name"] = f
    r["ext"] = file_ext(f)
    r["dirname"] = file_dirname(f)
    return 1
}

func split_query(query, r,    a, i, n) {
    split(query, a, "&")
    for(i in a) {
	n = index(a[i], "=")
	r["arg_" substr(a[i], 1, n-1)] = urldecode(substr(a[i], n+1))
    }
}
func split_uri(uri, r,    m) {
    delete r
    if(!match_uri(uri, m))
	return ""
    r["proto"] = m[2]
    r["user"] = m[4]
    r["pass"] = m[6]
    r["host"] = urldecode(m[7])
    r["domain"] = match_domain(urldecode(m[7]))
    r["port"] = m[9]
    r["path"] = urldecode(m[10])
    r["query"] = m[12]
    r["fragment"] = urldecode(m[14])
    split_query(r["query"], r)

    r["ext"] = file_ext(get("http_path"))
    r["file"] = file_basename(get("http_path")) wrap(".", r["ext"])
    r["dir"] = file_dirname(get("http_path"))

    r["remote"] = wrap("", r["user"], "@") r["host"]
    return r["proto"]
}
func join_uri(r,    s) {
    if(!r["proto"])
	return ""
    s =   r["proto"] "://" 
    s = s wrap("", r["user"] wrap(":" r["pass"]), "@")
    s = s urlencode(r["host"])
    s = s wrap(":", r["port"])
    s = s urlencode(r["path"])
    s = s wrap("?", r["query"])
    s = s wrap("#", urlencode(r["fragment"]))
    return s
}
func uri_cd(p, dir) {
    p = p "_"
    s =   get(p "proto") "://" 
    s = s wrap("", get(p "user") wrap(":" get(p "pass")), "@")
    s = s urlencode(get(p "host"))
    s = s wrap(":", get(p "port"))
    s = s urlencode(dir)
    return s
}

func split_xprop(s, r,    i, a, m) {
    delete r
    split(s, a, "\n")
    for(i = 1; i <= length(a); ++i) {
	if(match(a[i], /^WM_CLASS\(STRING\) = "(.*)", "(.*)"/, m)) {
	    r[q "res_name"] = m[1]
	    r[q "res_class"] = m[2] # use res_class to match applications
	    continue
	}

	if(match(a[i], /^([A-Za-z_]+)\(ATOM\) = "(.*)"$/, m) ||
	   match(a[i], /^([A-Za-z_]+)\(INTEGER\) = (.*)$/, m) ||
	   match(a[i], /^([A-Za-z_]+)\(CARDINAL\) = (.*)$/, m) ||
	   match(a[i], /^([A-Za-z_]+)\(STRING\) = "(.*)"$/, m) ||
	   match(a[i], /^([A-Za-z_]+)\(WINDOW\): window id # (.*)$/, m))
	    r[q m[1]] = m[2]

	if(match(a[i], /program specified size ([0-9]*): by ([0-9]*)$/, m))
	    r[q "hint_" gensub(/ /, "_", "g", m[1])] = m[2]
    }
}
