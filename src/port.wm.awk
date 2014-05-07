
@include "ctx.awk"
@include "class.awk"
@include "class.x11.awk"

BEGIN {
    teslawm_fifo = ENVIRON["TESLAWM_fifo"]
}

get("ctx.xprop.wm_class_name") == "Sonata" {
    set("ctx.xprop.wm_name", HOME "/mnt/ssh/rfigura@wirsing/home/rfigura/pub/audio/" get("ctx.xprop.wm_name"))
}

get("ctx.xwin") && teslawm_fifo {
    # todo: improve teslawm to accept a window id in commands:
    label("close"); menu("echo close " get("ctx.xwin") " > " Q(teslawm_fifo))
    label("movemouse"); menu("echo movemouse " get("ctx.xwin") " > " Q(teslawm_fifo))
    label("resizemouse"); menu("echo resizemouse " get("ctx.xwin") " > " Q(teslawm_fifo))
}
get("ctx.xwin") {
    menu("xkill -id " get("ctx.xwin"))
    menu(pager("xwininfo -id " get("ctx.xwin")))
    menu(pager("xprop -id " get("ctx.xwin")))
    label("wm_name..."); menu(nest(get("ctx.xprop.wm_name"), "open"))
#    label("teslawm rule (sel)"); menu("@xsel " get("ctx.xprop.wm_class_name") ":" get("ctx.xprop.wm_class") ":" get("ctx.xprop.wm_name"))
}

{
    set("pid", get("ctx.xprop.net_wm_pid"))
}
@include "port.pid.awk"
@include "port.default.awk"
