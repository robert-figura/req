
@include "class.awk"

get("num") {
    label("timestamp -> date")
    let("auto", 0+get("num") > 365*24*3600) # ???
    menu(pager("date -d @" Q(get("num")) " -R -u"))
}
get("date") {
    menu(pager("cal -3 " get("mday") " " get("mon") " " get("year")))
    label("date -> timestamp")
    # todo: filter_percent is evil:
    menu(pager("date '+%s' -d " Q(get("year") "-" get("mon") "-" get("mday") " " get("hour") ":" get("min") preif(":", get("sec")))))
}

get("num") {
    menu(pager("factor " Q(get("num"))))
}

func gp(f) {
    return "gp -q <(echo " Q("print(" QQ(f) ");\nprint(" f ")") ")"
}
func gnuplot(f) {
    return "gnuplot -e " Q("print " QQ(f) " ; plot " f) " -"
}

# oeis format:
match($0, /^\(PARI\) (.*)$/, m) {
    label("pari/gp"); menu(xterm(gp(m[1])))
}
get("formula") {
    label("pari/gp"); run(xterm(gp(get("formula"))))
    label("gnuplot"); run(xterm(gnuplot(get("formula"))))
    label("bc"); run(pager("echo " Q(get("formula")) " | bc"))
}

get("color") {
    WISH = "wish"
    c = "wm withdraw .\n"
    c = c "puts [tk_chooseColor -parent . -initialcolor \"#" get("color") "\" -title \"Tk color picker\"]\n"
    c = c "exit\n"
    label("colorpicker"); run("echo " Q(c) " | " WISH)
}
