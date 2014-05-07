
# process id
get("decimal") && set("pid_cmdline", getFile("/proc/" get("num") "/cmdline")) {
    set("pid", get("num"))
    n = split(get("pid_cmdline"), m, "\000")
    set("pid_exe", m[1])
    set("pid_args", "")
    for(i = 2; i < n; ++i)
	set("pid_args", get("pid_args") " " Q(m[i]))
    set("pid_cmdline", get("pid_exe") " " get("pid_args"))
}
