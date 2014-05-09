
func clearMenu() {
    delete menu_attr
    delete menu_dup
    delete menu_let
    menu_index = menu_count = 0
}
func endMenu() {
    # make sure following set() calls will not disturb previous ones
    menu_index = 0
    delete menu_let
}
func menu(cmd) {
    if(cmd == "") {
	endMenu()
	return
    }
    if(cmd in menu_dup) {
	verbose("menu (dup): " cmd)
	endMenu()
	return
    }

    let("label", word(cmd))
    
    # todo: using get() here does strange to the menu labels:
    if(menu_let["auto"])
	menu_let["label"] =  "* " menu_let["label"]
    
    verbose("menu: " cmd)
    menu_dup[cmd] = menu_index = ++menu_count
    menu_attr[menu_index]["cmd"] = cmd # implicitly make menu_attr[menu_index] an array
    copyArray(menu_def, menu_attr[menu_index])
    copyArray(menu_let, menu_attr[menu_index])
    delete menu_let
}
{
    delete menu_def
}

func dumpMenu(dummy) {
    runHook(notify(a2s(menu_attr)))
}

BEGIN {
    defAttr("menu_font", "-*-lucida-medium-r-*-*-17-*-*-*-*-*-iso10646-*")
    defAttr("menu_fg", "#000000")
    defAttr("menu_bg", "#eeeeee")
    defAttr("menu_sel_fg", "#ffffff")
    defAttr("menu_sel_bg", "#006699")
#    defAttr("menu_border", "#ff7f00")
}

func findLabel(items, label) {
    menu_discarded_input = ""
    for(i = 1; i <= menu_count; ++i)
#    for(i in items)
	if(items[i]["label"] == label)
	    return i
    menu_discarded_input = label
    return 0
}
func is_int(x) {
    return x ~ /^[0-9]+$/
}

func menu_auto(items,    i) {
    for(menu_index = 1; menu_index <= menu_count; ++menu_index)
#    for(i in items)
	if(get("auto")) # need menu_index to use get()
	    return menu_index
    return 0;
}
func menu_print(items,    sel) {
    if(sel = attr["select"])
	return sel ~ /[0-9]+/ ? sel : findLabel(items, sel)
    for(i = 1; i <= menu_count; ++i)
#    for(i in items)
	print i " - " items[i]["label"]
    quit(0)
}
func menu_pipe(items, cmd,    i, ret, rt) {
    for(i = 1; i <= menu_count; ++i)
#    for(i in items)
	print items[i]["label"] |& cmd
    close(cmd, "to")
    rt = RT
    cmd |& getline ret
    RT = rt
    close(cmd)
    return findLabel(items, ret);
}
func menu_req(items,    c) {
    return menu_pipe(items, "req " nest_args("menu") " -stdin")
}
func menu_dmenu(items,    c) {
    c = "dmenu -l 15 "
    c = c flag("-p", get("menu_prompt"))
    c = c flag("-fn", get("menu_font"))
    c = c flag("-nf", get("menu_fg"))
    c = c flag("-nb", get("menu_bg"))
    c = c flag("-sf", get("menu_sel_fg"))
    c = c flag("-sb", get("menu_sel_bg"))
    return menu_pipe(items, c)
}
func menu_9menu(items,    c) {
    c = "9menu -teleport -shell /bin/echo -popup"
    for(menu_index = 1; menu_index <= menu_count; ++menu_index)
#    for(i in items)
	c = c " " Q(items[menu_index]["label"] ":" menu_index)
    return trim(substr(btick("killall -q 9menu 2> /dev/null || " c), 3))
}

func menu_default(items) {
    # term detection does not always work. e.g.:
    # $ hgtk commit -> file -> edit launches req via $EDITOR,
    # but menu is printed to term
#    if(get("term"))
#	return menu_print(items)
    return menu_dmenu(items)
}
func menu_sort_auto(ai, a, bi, b) {
    if(a["auto"] == b["auto"])
	return ai - bi
    return a["auto"] ? -1 : 1;
}
func choice(    items, hook) {
    if(!menu_count)
	return 0

    delete menu_attr[0]
    delete menu_attr[""]
#    asort(menu_attr, items, "menu_sort_auto")
    
    if(!attr["menu"] && !attr["select"])
	if(menu_index = menu_auto(menu_attr)) {
	    verbose("menu auto: " menu_index)
	    return menu_index
	}
    hook = attr["menu"] ? "menu_" attr["menu"] : "menu_default"
    menu_index = @hook(menu_attr)
#    menu_index = @hook(items)
    verbose("menu selected: " menu_index)
    return menu_index
}
