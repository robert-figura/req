
# discoverable hotkey event matcher
func hotkey(key,    m, k, i, j, r) {
    if(!match($0, /^xbindkeys:(.*)$/, m))
	return 0
    split(key, k, " *\\+ *")
    split(m[1], i, " *\\+ *")
    for(j in k)
	r[k[j]]++
    for(j in i)
	r[i[j]]--
    for(j in r)
	if(j && r[j])
	    return 0
    return 1
}

func restart() {
    system("killall xbindkeys > /dev/null")
    exit 101
}

# log_gauge
function abs(x) {
    return x > 0 ? x : -x;
}
func gauge_max(m, file, max_file) {
    if(max_file)
	return int(file_get(max_file))
    if(m > gauge_file_max[file])
	gauge_file_max[file] = m
    return int(gauge_file_max[file])
}
func log_gauge(fact, file, max_file,    b, m) {
    b = int(file_get(file))
    m = gauge_max(b, file, max_file)
    b = int(fact > 0 ? b*abs(fact) + 1 : b/abs(fact))
    if(b < 0) b = 0
    if(b > m) b = m
    file_put(file, b)
}

# amixer
func amixer(cmd,    a) {
    pipe("amixer -s > /dev/null", cmd)
}
