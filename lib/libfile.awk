
func fd_register(fd) {
    fd_map[fd]++
}
func fd_close_all(    fd) {
    for(fd in fd_map)
	close(fd)
}

func file_classifier(fn, cmd,    ret, m, rt) {
    fd_register(cmd)
    print fn |& cmd
    rt = RT
    cmd |& getline ret
    RT = rt
    return ret
}
func file_mimetype(fn,    ret, m) {
    ret = file_classifier(fn, "exec file -Lib -n -f - ")
    if(ret ~ /^ERROR:/ || # works for file 5.11
       ret ~ /^cannot open `/) # works for file 5.18 
	return ""
    split(ret, m, ";")
    return m[1]
}
func file_type(fn,    cmd, ret, m, rt) {
    ret = file_classifier(fn, "exec file -Lb -n -f - ")
    if(ret ~ /^ERROR:/ || # works for file 5.11
       ret ~ /^cannot open `/) # works for file 5.18 
	return ""
    return ret;
}
func file_basename(f,    m) {
    return (match(f, /^(.*\/)?([^/]*)(\.[^./]+)$/, m) || match(f, /^(.*\/)?([^/]*)$/, m)) ? m[2] : ""
}
func file_dirname(f,    m) {
    if(f ~ /^\/[^/]*$/)
	return "/"
    return match(f, /^(.*)\/[^/]*\/?$/, m) ? m[1] : ""
}
func file_ext(f,    m) {
    return match(f, /^(.*\/)?[^/]*\.([^./]+)$/, m) ? m[2] : ""
}

func file_get(file,    l, i, ret, rt) {
    i = 0
    rt = RT
    for(ret = ""; (getline l < file) > 0; ret = ret l)
	if(i++)
	    ret = ret "\n";
    RT = rt
    close(file)
    return ret
}
func file_put(fn, str) {
    printf "%s", str > fn
    close(fn)
}
func file_get_map(file, ret, prefix, sep,    l, i, rt) { # todo: flip prefix and sep argument order?
    rt = RT
    if(!sep)
	sep = "="
    while((getline l < file) > 0) {
	i = index(l, sep)
	if(i > 1)
	    ret[substr(l, 1, i-1)] = substr(l, i+1)
    }
    close(file)
    RT = rt
}
func file_put_map(file, a, sep,    i) {
    if(!sep)
	sep = "="
    for(i in a)
	if(a[i] != "")
	    print i sep a[i] > file
    close(file)
}

func tmp_cleanup(    c, i, t) {
    if(get("tmpkeep")) {
	split(get("tmpkeep"), t)
	for(i in t)
	    delete tmp_files[t[i]]
    }
    for(i in tmp_files)
	if("" i)
	    c = c " " Q(i)
    if(c)
	system("rm " c)
    delete tmp_files
}
func tmp_name(key) {
    ++tmp_name_count
    return TEMP "/" systime() "-" PROCINFO["pid"] "-" tmp_name_count wrap(".", key)
}
func tmp_file(f) {
    tmp_files[f]++
}
func tmp_keep(f) {
    setChoice("tmpkeep", get("tmpkeep") " " f)
}
