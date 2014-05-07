
# a simple front end to reqs menu engines. used for favorites, history, etc.

BEGIN {
    REQ_VERBOSE = 0
    attr["run_hook"] = "print"
    attr["run_per_record"] = ""
    if(attr["port"] == "menu" && attr["via"])
	attr["port"] = attr["via"]
    attr["filter_percent"] = 0
}

# skip empty and comment lines in favorites
attr["from"] == "favorites" && /^ *(#.*)?$/ {
    --NR; --FNR
    next
}

attr["q"] == "_SURF_GO" {
}
attr["q"] == "_SURF_FIND" {
}

{
    label($0)
    if(match($0, /^(.*) #.*$/, m))
	menu(m[1])
    else
	menu($0)
}
END {
    doIt()
    if(menu_discarded_input)
	print menu_discarded_input
}
