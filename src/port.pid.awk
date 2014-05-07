
# process tools
get("pid") {
    pid = get("pid")
    pid_cmdline = get("pid_cmdline")
    pid_args = get("pid_args")
    pid_exe = get("pid_exe")
    label("proc state"); menu(pager("echo " Q(pid_cmdline) " ; cat " Q("/proc/" pid) "/{status,io,stack}"))
    label("proc fd"); menu(pager("ls -l " Q("/proc/" pid "/cwd") " " Q("/proc/" pid "/fd/") "* | cut -d' ' -f10-"))
    label("proc mmaps"); menu(pager("cat " Q("/proc/" pid "/smaps") " | grep /"))
    label("pmap"); menu(pager("pmap " Q(pid)))
    label("process tree"); menu(pager("ps x --forest") " " Q("+/^ *" pid))
    menu(xterm("strace -p" Q(pid)))
    menu(xterm("ltrace -p " Q(pid)))
    label("SIGTERM"); menu("kill -TERM " Q(pid))
    label("SIGKILL"); menu("kill -KILL " Q(pid))
    label("SIGCONT"); menu("kill -CONT " Q(pid))
    label("SIGSTOP"); menu("kill -STOP " Q(pid))
}
