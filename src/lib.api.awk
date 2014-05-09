
# array tools
func copyArray(a, b) {
    for(i in a)
	b[i] = a[i]
}
func a2s(a,    p, s, i) {
    if(!isarray(a))
	return a
    s = ""

    PROCINFO["sorted_in"] = "@ind_str_asc"
    for(i in a)
	if(isarray(a[i]))
	    s = s a2s(a[i], p i ".")
	else if(a[i] != "")
	    s = s p i " = " a[i] "\n"
    return s
}

# debug tools
func verbose(msg) {
    if(REQ_VERBOSE)
	print msg > "/dev/stderr"
}
func dumps() {
    return "$0 = " $0 "\n" a2s(attr, "attr.") "\n" a2s(ctx) "\n" a2s(class, "class.")
}
# dummy: suppress warning when called as @hook command from menu:
func dump(dummy) {
    runHook(notify(dumps()))
}

# tmpfile tools
func tmpname(key) {
    ++tmpname_count
    return systime() "-" PROCINFO["pid"] "-" tmpname_count preif(".", key)
}
func tmpfile(key,    f) {
    f = TEMP "/" tmpname(key);
    ++tmpfiles[f];
    return f;
}
func cleanup(    c, f) {
    c = "rm -f"
    for(f in tmpfiles) {
	verbose("remove: " f)
	c = c " " Q(f)
    }
    system(c)
    delete tmpfiles
    for(f in close_list)
	close(f)
    delete close_list
}

# read header files
func readHeader(filename,    l, m, rt) {
    rt = RT
    while((getline l < filename) > 0)
	if(match(l, /^([^=]+)=(.*)$/, m))
	    attr[m[1]] = m[2]
    close(file)
    RT = rt
}

# some shortcuts
func label(str) {
    let("label", str)
}
func cd(dir) {
    def("pwd", dir)
}
func run(cmd) {
    let("auto", 1)
    menu(cmd)
}

func hook(type, f, arg) {
    f = postif(type, "_") f
    return @f(arg)
}

func runHook(arg,    m) {
    verbose("exec: " arg)
    if(attr["run_hook"] == "print")
	run_print(arg);
    else if(match(arg, /^@([a-zA-Z_][0-9a-zA-Z_]*)( +(.*))?$/, m))
	hook("", m[1], m[3]) # todo: use "at" here (need to update all function names called that way)
    else
	hook("run", attr["run_hook"], arg)
    quit(0)
}
func run_print(cmd) {
    print cmd
}
func run_system(cmd) {
    system(cmd)
}
func run_spawn(cmd) {
    system(cmd " &")
}
# exec() comes with awk -l exec.so ...
func run_exec(cmd) {
    # earlier extension api was better because we could react on missing exec.so
#    if(extension("exec.so", "dl_load"))
#	run_system(cmd)
    cleanup()
    exec(cmd)
    # this should also execute the END block:
#    exec(cmd, 1)
}

func doIt() {
    if(choice())
	runHook(get("cmd"))
    clearMenu()
}

# recusive invocations of req:
func export(name, value) {
    if(value)
	attr[name] = value
    export_list[name]++
}
func nest_args(p, m,    a, i) {
    if(p)
	let("label", p "...")
    m[0] ; delete m[0] # type conversion # todo: is that effective here at all??
    
    copyArray(attr, m)
    delete m["format"]
    delete m["port"]
    m["via"] = attr["port"]
    for(i in m)
	if("" m[i])
	    a = a " -a " Q(i "=" m[i])
    
    for(i in export_list)
	a = a " -a " Q(i "=" get(i))
    return a preif(" -p ", p)
}
# todo: pass message files
# todo: directly call awk, skip front-end
func nestcmd(str, p, m) {
    return "req " nest_args(p, m) " -alias " str
}
func nest(str, p, m) {
    return "req " nest_args(p, m) " " Q(str)
}

# read all remaining records now
func collapse(s,    t) {
    while((getline t) > 0)
	s = s "\n" t
    return s
}

func quit(i) {
    cleanup()
    exit i
}
