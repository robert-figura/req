
@include "ctx.awk"
@include "class.awk"
@include "class.x11.awk"

BEGIN {
    teslawm_fifo = ENVIRON["TESLAWM_fifo"]
}

get("xprop.wm_class_name") == "Sonata" {
    set("xprop.wm_name", HOME "/mnt/ssh/rfigura@wirsing/home/rfigura/pub/audio/" get("xprop.wm_name"))
}

get("xwin") && teslawm_fifo {
    # todo: improve teslawm to accept a window id in commands:
    label("close"); menu("echo close " get("xwin") " > " Q(teslawm_fifo))
    label("movemouse"); menu("echo movemouse " get("xwin") " > " Q(teslawm_fifo))
    label("resizemouse"); menu("echo resizemouse " get("xwin") " > " Q(teslawm_fifo))
}
get("xwin") {
    menu("xkill -id " get("xwin"))
    menu(pager("xwininfo -id " get("xwin")))
    menu(pager("xprop -id " get("xwin")))
    label("wm_name..."); menu(nest(get("xprop.wm_name"), "open"))
#    label("teslawm rule (sel)"); menu("@xsel " get("xprop.wm_class_name") ":" get("xprop.wm_class") ":" get("xprop.wm_name"))
}

{
    set("pid", get("xprop.net_wm_pid"))
}
@include "port.pid.awk"
@include "port.default.awk"
