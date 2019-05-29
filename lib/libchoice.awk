
func hook(type, f, arg) {
    f = wrap("", type, "_") f
    if("" arg)
	return @f(arg)
    return @f()
}

func select(s) {
    for(cid = 1; cid <= nchoices; ++cid)
	if(cid == s || get("label") == s)
	    return cid
    cid = 0
}
func pipemenu(cmd,    i, ret, rt) {
    for(cid = 1; cid <= nchoices; ++cid)
	if(get("auto"))
	    print get("label") |& cmd
    for(cid = 1; cid <= nchoices; ++cid)
	if(!get("auto"))
	    print get("label") |& cmd
    close(cmd, "to")
    rt = RT
    cmd |& getline ret
    RT = rt
    close(cmd)
    return select(ret)
}

func menu_dmenu() {
    return pipemenu(dmenu())
}
func menu_print() {
    for(cid = 1; cid <= nchoices; ++cid)
	print cid " - " get("label")
    return cid = 0
}

func mark_auto_in_label() {
    for(cid = 1; cid <= nchoices; ++cid)
	if(get("auto"))
	    choice_map[cid ".label"] = "* " choice_map[cid ".label"]
}
func picker() {
    if(nchoices < 1)
	return cid = 0
    if(get("mode") == "list") {
	for(cid = 1; cid <= nchoices; ++cid)
	    print get(get("prop"))
	return cid = 0
    }
    if("" get("select"))
	return select(get("select"))
    
    if(!(0+get("no_auto")))
	for(cid = 1; cid <= nchoices; ++cid)
	    if(get("auto"))
		return cid
    hook("menu", get("menu"))
    return cid
}
func history(s,    fd) {
    if(0+get("no_history") || get("from") == "history")
	return
    if(!s) s = get("history_override")
    if(!s) s = $0
    fd = expand_tilde(get("history"))
    print s >> fd
    close(fd)
}
func runChoice(    c) {
    if(get("mode") == "run") {
	history()
	if(get("run") == "call")
	    hook("", get("call_cmd"), get("call_arg"))
	else if(c = get("cmd"))
	    hook("run", get("run"), c)
    }
    else if(get("mode") == "test")
	print get(get("prop"))
    else if(get("mode") == "dump")
	print dump2string()
}

func choose() {
    if(get("mode") == "class") {
	print class(get("prop"))
	return
    }
    if(get("mode") == "dump_class") {
	printClass()
	return
    }
    mark_auto_in_label()   
    if(picker())
	runChoice()
    deleteChoices()
}
