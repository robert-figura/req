
### shell api

BEGIN {
    SHELL = ENVIRON["SHELL"]
    if(!SHELL)
	SHELL = "/bin/sh"
}
func shell(cmd) {
    # todo: do -c exec here? to save a process:
    return SHELL " -c " Q(cmd)
}
func Q(s) {
    # quote ' -> '\'', and enclose in '
    return "'" gensub(/'/, "'\\\\''", "g", s) "'"
}
func QQ(s) {
    # quote " and \ using \, and enclose in "
    return "\"" gensub(/([\\"])/, "\\\\\\1", "g", s) "\""
}
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
func btick(cmd,    ret) {
    verbose("backtick: " cmd)
    ret = backtick(cmd (REQ_VERBOSE ? "" : " 2> /dev/null"))
    verbose("backtick return: " ret)
    return ret
}
func spawn(cmd) {
    verbose("spawn: " cmd)
    system("exec " cmd " &")
}

BEGIN {
    PAGER = ENVIRON["PAGER"]
    if(!PAGER)
	PAGER = "more"
}
# the default pager is a filter
func pager_cat(cmd) {
    return cmd " | " PAGER
}
# some pagers may allow other modes of operations:
func pager_file(file) {
    return pager_cat("cat " Q(file))
}
func pager_str(str) {
    return pager_cat("echo " Q(str))
}

func pager(cmd, p) {
    if(!p)
	p = ENVIRON["PAGER"]
    if(!p)
	p = "less"
    let("label", word(cmd))
    export("xterm_title", cmd)
    # todo: term is recognized through hotkey??:
#    if(attr["term"])
#	return cmd " | " pager;
    return xterm(bash(cmd " | " p))
}
