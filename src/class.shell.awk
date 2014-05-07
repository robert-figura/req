
# note that the following only works in -alias mode:
# todo: add patterns to indicate that, the code is the documentation

{
    # construct command and exe
    c = ""
    for(i = 1; i <= NF; ++i)
	c = c " " Q($i)
    set("command", c)
    set("exe", $1)

    # todo: initialize using attr
    xterm_flags = ""
}

# todo: move to class.shell.awk?:
# try to unwrap prefix commands, to get more information out of it:
get("exe") == "xterm" {
    # todo: there must be a more elegant way to work on $foo, maybe convert to/from R[] array and use array tools...
    for(i = 2; i <= NF; ++i) {
	if($i == "-e") {
	    ++i
	    break
	}
	xterm_flags = xterm_flags " " $i
    }
    c = s = $i
    set("exe", $i)
    for(++i; i <= NF; ++i) {
	c = c " " Q($i)
	s = s FS $i
    }
    set("command", c)
    $0 = s
}
function findFlag(flag) {
    for(i = 2; i <= NF; ++i)
	if($i == flag)
	    return $(i+1)
    return ""
}
get("exe") == "bash" && (c = findFlag("-c")) {
    match(c, /^([^ ]*) /, m)
    # todo: explode bash -c argument, how??
    set("exe", m[1])
}
get("exe") == "ssh" {
    for(i=2; i <= NF; ++i) {
	if($i !~ /^-/)
	    break
	ssh_flags[i] = $i
    }
    match($i, /^(([^@]+)@)?(.*)$/, m)
    set("ssh.user", trim(m[2]))
    set("ssh.host", trim(m[3]))
    ++i
    set("ssh.exe", trim($i))
    c = ""
    for(; i <= NF; ++i)
	c = c " " $i
    set("ssh.command", c)
}
