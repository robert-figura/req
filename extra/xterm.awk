
@include "libstring.awk"

# This is a wrapper for the xterm command. It is not a port file!
# Use it with bin/req-wrapper, which will generate an input line for every argument.

# CAVEAT: doesn't handle nested calls to the same command well (for example:
# `xterm -e ssh foo ssh bar` will overwrite settings of the outer ssh call with
# the ones for the inner one).

# CAVEAT: doesn't handle single arguments that really are commandlines
# (for example: xterm -e sh -c 'ssh foo ...' will not recognize the ssh command).

NR == 1 {
    split($1, a, "/")
    cmd = a[length(a)]
    binary = cmd
    next
}
{
    A[NR] = $0
    flag = ""
}
A[NR-1] ~ /^-/ {
    flag = A[NR-1]
}

################################################################

xterm_cmd {
    xterm_cmd = xterm_cmd " " Q($0)
}
cmd == "xterm" && flag == "-e" {
    cmd = xterm_cmd = $0
}
cmd == "xterm" && flag == "-bg" {
    xterm_bg = $0
}
cmd == "xterm" && flag == "-fg" {
    xterm_fg = $0
}
cmd == "xterm" && flag == "-title" {
    xterm_title = $0
}

sudo_cmd {
    sudo_cmd = sudo_cmd " " Q($0)
}
cmd == "sudo" && !flag {
    cmd = sudo_cmd = $0
}

# todo: sh -c expects a whole commandline as single argument, should we care? how? recursion?

# todo: ssh effectively deqotes its arguments. dequoting these here should be more clean...
ssh_cmd {
    ssh_cmd = ssh_cmd " " Q($0)
}
cmd == "ssh" && !flag && ssh_target {
    cmd = ssh_cmd = $0
}
cmd == "ssh" && !flag && !ssh_target {
    ssh_target = $0
    split(ssh_target, a, "@")
    ssh_user = a[2] ? a[1] : ENVIRON["USER"]
    ssh_host = a[2] ? a[2] : a[1]
}
cmd == "ssh" && flag == "-p" {
    ssh_port = $0
}

# todo: sh -c expects a whole commandline as single argument, should we care? how? recursion?
cmd ~ /(sh|bash)/ && flag == "-c" {
    sh_cmd = $0
    cmd = word(sh_cmd)
}

################################################################

func xtermcolors(fg, bg) {
    if("" xterm_fg)
	return
    xterm_fg = fg
    xterm_bg = bg
}

ssh_host ~ /^10\.8\.2\./ { # gcash ipsec customer pool
    xtermcolors("white", "#993333")
}
is_in(ssh_host, "\
rpi \
192.168.0.187 \
") {
    xtermcolors("white", "#663333") # raspberry
}
is_in(ssh_host, "\
wirsing.deinding.net wirsing 10.0.0.1 \
") {
    xtermcolors("white", "#001800")
}
is_in(ssh_host, "\
dg1 109.239.58.97 \
dg3 46.252.27.202 \
dg4 109.239.58.182 \
") {
    if(ssh_user == "root")
	xtermcolors("#ffbb66", "#331100") # bernstein
    else
	xtermcolors("#aaffaa", "#002200") # monochrome green
}
ssh_user == "root" {
    xtermcolors("#77ff77", "black")
}

cmd == "su" || cmd == "sudo" {
    xtermcolors("white", "red4") # local root
}
is_in(cmd, "\
alsamixer \
iftop \
iotop \
mpv \
ping \
powertop \
top \
wpa_cli \
") {
    xtermcolors("white", "black")
}

xterm_title == "mpv" ||
cmd ~ /youtube-playlist$/ ||
cmd ~ /dl$/ {
    xtermcolors("lightblue", "black")
}

/^-?help$/ ||
/[^|]\| *less$/ || # as in: sh -c '... | less'
cmd ~ /^(info|man|less)$/ {
    xtermcolors("black", "#eeeeee")
}

################################################################

BEGIN {
    xterm_bg = ""
    xterm_fg = ""
    xterm_font = ""
    xterm_title = ""
}

END {
    system("rm " Q(FILENAME))
    
    if(!xterm_title)
	xterm_title = xterm_cmd

    c = "xterm"
    c = c wrapQ(" -bg ", xterm_bg)
    c = c wrapQ(" -fg ", xterm_fg)
    c = c wrapQ(" -fn ", xterm_font)
    c = c wrapQ(" -title ", xterm_title)
    c = c wrap(" -e ", xterm_cmd)
    exec(c)
}
