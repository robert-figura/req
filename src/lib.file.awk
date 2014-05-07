
# files
func file_mimetype(fn,    cmd, ret, m, rt) {
    cmd = "exec file -Lib -n -f - "
    close_list[cmd]++
    print fn |& cmd
    rt = RT
    cmd |& getline ret
    RT = rt
    split(ret, m, ";")
    if(m[1] ~ /^ERROR:/ || # works for file 5.11
       m[1] ~ /^cannot open `/) # works for file 5.18 
	return ""
    return m[1]
}
func file_basename(f,    m) {
    return (match(f, /^(.*\/)?([^/]*)(\.[^./]+)$/, m) || match(f, /^(.*\/)?([^/]*)$/, m)) ? m[2] : ""
}
func file_dirname(f,    m) {
    return match(f, /^(.*)\/[^/]*$/, m) ? m[1] : ""
}
func file_ext(f,    m) {
    return match(f, /^(.*\/)?[^/]*\.([^./]+)$/, m) ? m[2] : ""
}

# directories
func realpath(dir) { # roughly equivalent to: cd / ; realpath -m "$dir"
    dir = gensub(/\/+/, "/", "g", dir)
    dir = gensub(/\/+$/, "", 1, dir)
    while(dir != (dir = gensub(/\/[^\/]+\/\.\.\//, "/", "g", dir)));
    dir = gensub(/\/[^\/]+\/\.\.$/, "", 1, dir)
    return dir
}

# file io
func getFile(file,    l, i, ret, rt) {
    i = 0
    rt = RT
    for(ret = ""; (getline l < file) > 0; ret = ret l)
	if(i++)
	    ret = ret "\n";
    RT = rt
    close(file)
    return ret
}
function putFile(fn, str) {
    printf "%s", str > fn
    close(fn)
}
func readlist(f, i, fs, ret,    l) {
    rt = RT
    while((getline l < f) > 0)
	ret[word(l, i, fs)]++
    RT = rt
    close(f)
    return length(ret)
}

func split_file(f, ret, prefix,   m) {
    if(!prefix)
	prefix = "file"
    if(!(m = file_mimetype(f)))
	return 0
    ret[prefix, "mimetype"] = m
    if(m == "inode/directory") {
	ret[prefix, "directory"] = f
	ret[prefix, "dirname"] = f
	return 1
    }
    ret[prefix, "name"] = f
    ret[prefix, "dirname"] = file_dirname(f)
    return 1
}
