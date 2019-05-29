
NR == 1 {
    next
}

NR == 2 {
    exe = $0
    next
}
NR == 3 {
    part = $0
    next
}
NR == 4 {
    prev = $0
}

prev == exe {
    prev = ""
    delete seen
}

func compAdd(str) {
    if(str !~ /^[a-zA-Z0-9/.:_\=,+-]*$/)
	str = Q(str)
    print str
}
func trim(s) {
    s = gensub(/^[ \t\n\r]*/, "", 1, s)
    s = gensub(/[ \t\n\r]*$/, "", 1, s)
    return s
}
func pipeAdd(prefix, cmd, fs, idx,    rt, line, b, k) {
    rt = RT
    if(!fs)
	fs = " "
    if(!idx)
	idx = 1
    while((cmd |& getline line) > 0) {
	split(trim(line), b, fs)
	if(b[idx] && (index(b[idx], prefix) == 1))
	    compAdd(b[idx])
    }
    close(cmd)
    RT = rt
    return ret
}
func Q(s) {
    # substitute ' -> '\'' and enclose in '
    return "'" gensub(/'/, "'\\\\''", "g", s) "'"
}

# command switch
part ~ /^-/ { #  | col -bp 2>...
    pipeAdd(part, "GROFF_NO_SGR=1 man " Q(exe) " 2> /dev/null")
    next
}

func fileAdd(pp, prefix, file,    line, i, ret, rt) {
    rt = RT
    for(i=0; (getline line < file) > 0; ++i) {
	split(line, b, " ")
	line = b[1]
	if(line && (index(line, pp prefix) == 1))
	    compAdd(substr(line, length(pp)+1))
    }
    close(file)
    RT = rt
    return ret
}

exe == "ssh" {
    fileAdd("ssh://", part, ENVIRON["HOME"] "/.favorites")
    next
}
