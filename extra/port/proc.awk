
# classify process id
match($0, /^([0-9]+)/, m) && (c = file_get("/proc/" m[1] "/cmdline")) {
    set("pid", 0+m[1])
    n = split(c, m, "\000")
    set("pid_exe", m[1])
    set("pid_args", "")
    for(i = 2; i < n; ++i)
	set("pid_args", get("pid_args") " " Q(m[i]))
    set("pid_cmdline", get("pid_exe") " " get("pid_args"))
}

# process tools
get("pid") {
    p = get("pid")
    label("proc fd"); menu(pager("ls -l " Q("/proc/" p "/cwd") " " Q("/proc/" p "/fd/") "* | cut -d' ' -f10-"))
    label("proc state"); menu(pager("( echo COMMANDLINE: " Q(get("pid_cmdline")) " ; cat " Q("/proc/" p) "/{io,status} )"))
    label("proc mmaps"); menu(pager("cat " Q("/proc/" p "/smaps") " | grep /"))
    menu(xterm("gdb --pid=" Q(p)))
    menu(pager("ldd \"`which " Q(get("pid_exe")) "`\""))
    menu(xterm("ltrace -p " Q(p)))
    menu(pager("pmap " Q(p)))
    menu(xterm("strace -p" Q(p)))
    label("kill -CONT"); menu("kill -CONT " Q(p))
    label("kill -STOP"); menu("kill -STOP " Q(p))
    label("kill -TERM"); menu("kill -TERM " Q(p))
    label("kill -KILL"); menu("kill -KILL " Q(p))
}
