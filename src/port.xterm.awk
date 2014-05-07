
# this is a wrapper for xterm. knows how to bg-color e.g. `xterm -e ssh myhost`
# put this in you .bashrc:
# alias xterm='req -p xterm -alias xterm'
# export TERMINAL='req -p dispatch -f TERMINAL'

@include "class.shell.awk"

function xtermcolors(fg, bg) {
    attr["xterm_fg"] = fg
    attr["xterm_bg"] = bg
}

{
    # there is only one thing to do, no need for menu
    attr["menu"] = ""
}

get("ssh.user") == "root" {
    xtermcolors("red", "black")
}
get("ssh.host") ~ /^(wirsing|10\.0\.0\.1|wirsing\.deinding\.net)$/ {
    xtermcolors("white", "#001800")
}
get("ssh.host") ~ /^(kartoffel|192\.168\.1\.189)$/ {
    xtermcolors("white", "#404030")
}
get("ssh.host") ~ /^(dg1|109\.239\.58\.97|dg2|109\.239\.58\.182|dg3|46\.252\.27\.202)$/ {
    xtermcolors("white", "#101030")
    if(get("ssh.user") == "root")
	xtermcolors("white", "#301040");
}
get("ssh.host") {
    attr["xterm_title"] = postif(get("ssh.user"), "@") get("ssh.host") ":"
}

get("exe") ~ "^alsamixer|arp|iwlist|ifconfig|netstat|nmap|ps|route|top|wpa_cli$" {
    xtermcolors("white", "black")
}
get("exe") == "su" {
    xtermcolors("white", "red4")
}

/ -?help/ ||
get("exe") ~ /(info|man|less)/ {
    xtermcolors("black", "white")
}
get("exe") ~ /download/ {
    xtermcolors("lightblue", "black")
    attr["xterm_title"] = "Progress:" $3 " " attr["download_data"]
}

{
    xterm_flags = xterm_flags flag("-bg", get("xterm_bg"))
    xterm_flags = xterm_flags flag("-fg", get("xterm_fg"))
    xterm_flags = xterm_flags flag("-fn", get("xterm_font"))
    xterm_flags = xterm_flags flag("-title", get("xterm_title"))
    
    run("xterm " xterm_flags preif(" -e ", get("command")))
    # urxvt breaks the alt key. guessed as much, all terms are broken badly
#    run("urxvt -j -ss -fade 20 -vb -sb +sr +si -sk -ptab -sl 500 -tcw +ssc " xterm_color preif(" -e ", get("command")))
}
