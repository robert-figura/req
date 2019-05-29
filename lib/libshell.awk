
func backtick(cmd,    line, ret, rt) {
    cmd = trim(cmd)
    rt = RT
    ret = ""
    while((cmd |& getline line) > 0)
	ret = ret line "\n"
    RT = rt
    close(cmd)
    return ret
}
func pipe(c, msg,    fd) {
    fd_register(fd = build_env() "exec " c)
    print msg | fd
    fflush(fd)
}

func expand_tilde(p) {
    return gensub(/^~\//, HOME "/", 1, p)
}

func cd(p) {
    setChoice("pwd", p)
}
func build_cd(p) {
    if(!p)
	p = get("pwd")
    return wrapQ("cd ", p, " ; ")
}

func env(k, v) {
    if("" v)
	setChoice(k, v)
    setChoice("env", choice("env") " " k)
}
func export(k, v) {
    if("" v)
	setArg(k, v)
    setArg("env", arg("env") " " k)
}
func build_env(    m, i, s) {
    split(arg("env") " " choice("env"), m, " ")
    for(i in m)
	s = s " " m[i] "=" Q(get(m[i]))
    return wrap("export ", s, " ; ")
}

# choice run handlers
func run_system(c) {
    system(build_cd() build_env() c)
}
func run_spawn(c) {
    system(build_cd() build_env() c " &")
}
func run_exec(c) {
    exec(build_cd() build_env() "exec " c, 1)
    exit 0
}
