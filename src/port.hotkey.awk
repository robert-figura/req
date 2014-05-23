
# loop endlessly on file list, e.g. to reopen pipe after eof:
# FNR == 1 { ARGV[ARGC++] = FILENAME }

func hotkey(key,    k, i, j, r) {
    if(attr["from"] != "hotkey") # todo: why??
	return 0
    split(key, k, " *\\+ *")
    split($0, i, " *\\+ *")
    for(j in k)
	r[k[j]]++
    for(j in i)
	r[i[j]]--
    for(j in r)
	if(j && r[j])
	    return 0
    return 1
}

# todo: disable TERM possibly recognized.

BEGIN {
    verbose("start listening to xbindkeys...")
}
hotkey("mod4+F1") {
    verbose("restarting, please wait...")
    system("killall xbindkeys")
    quit(1)
}

function abs(x) {
    return x > 0 ? x : -x;
}
function brightness(sys_dir, steps,    m, b) {
    m = int(getFile(sys_dir "/max_brightness"))
    b = int(getFile(sys_dir "/brightness"))
    b = b + int(m / steps)
    if(b < 0) b = 0
    if(b > m) b = m
    putFile(sys_dir "/brightness", int(b))
}


hotkey("mod4+F3") {
    brightness("/sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight", -3)
}
hotkey("mod4+F4") {
    brightness("/sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight", +3)
}

hotkey("mod4+F5") {
    # using sys is too crude, after screensaver xorg will restore the value set by xbacklight
#    brightness("/sys/class/backlight/intel_backlight", -24)
    system("xbacklight -dec 10 -time 1")
}
hotkey("mod4+F6") {
#    brightness("/sys/class/backlight/intel_backlight", +24)
    # x11 brightness is internally an integer < 10 :-(
    system("xbacklight -inc 10 -time 1")
}

func amixer(cmd,    a) {
    a = "exec amixer -s > /dev/null"
    print cmd | a
    fflush(a)
}
hotkey("mod4+F10") {
    amixer("sset Master toggle")
}
hotkey("mod4+F11") {
    amixer("sset Master 2-")
}
hotkey("mod4+F12") {
    amixer("sset Master 2+")
}

# send x11 selection to port.open 
hotkey("mod4+a") {
    spawn("req -f hotkey -p open \"$(xclip -o)\"")
}
hotkey("shift+mod4+a") {
    spawn("req -f hotkey -p open -menu \"$(xclip -o)\"")
}

# todo: port file menus to port.dispatch.awk:
function menucolors(fg, bg, selfg, selbg,    s) {
    s =   flag("-a", "menu_fg=" fg)
    s = s flag("-a", "menu_bg=" bg)
    s = s flag("-a", "menu_sel_fg=" selfg)
    s = s flag("-a", "menu_sel_bg=" selbg)
    return s
}
function favmenu(f1, f2, f3, f4, f5,    c) {
    if(!f1) {
	f1 = attr["favorites"]
	f2 = attr["bookmarks"]
    }
    c = menucolors("#ffffff", "#006699", "#000000", "#ffffff")
    return "req -p menu " c " -f favorites -a filter_uniq=1 -file " files(f1, f2, f3, f4, f5)
}
function histmenu(f1, f2, f3, f4, f5,    c) {
    if(!f1)
	f1 = attr["history"]
    c = menucolors("#ffffff", "#444444", "#000000", "#ff7f00")
    return "req -p menu " c " -f history -a filter_uniq=1 -rfile " files(f1, f2, f3, f4, f5)
}

# favorites menu
hotkey("mod4+s") {
    spawn(favmenu() " | req -p start -f favorites -stdin")
}
hotkey("shift+mod4+s") {
    spawn(favmenu() " | req -p start -f favorites -menu -stdin")
}

# history menu
hotkey("mod4+d") {
    spawn(histmenu() " | req -p open -f history -menu -stdin")
}

# wm menu
hotkey("mod4+m") {
    c = menucolors("#ffffff", "#ff7f00", "#000000", "#ffffff")
    spawn("req -menu " c " -p wm -f wm -percent %ctx.xwin")
}

# window title menu
hotkey("mod4+n") {
    c = menucolors("#ffffff", "#006699", "#ffffff", "#ff7f00")
    spawn("req -menu " c " -p wm_name -f wm -percent %ctx.xprop.wm_name")
}

# copy selection -> clipboard
hotkey("mod4+c") {
    system("xclip -o | xclip -selection clipboard -i")
}
# copy clipboard -> selection
hotkey("mod4+v") {
    system("xclip -selection clipboard -o | xclip -i")
}

# performance: include dispatch here and use a pipe?
