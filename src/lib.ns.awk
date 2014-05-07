
func get(key) {
    # todo: this will work only after menu() call...:
    if(isarray(menu_attr[menu_index]) && key in menu_attr[menu_index])
	return menu_attr[menu_index][key]
    # ... also need menu_let?:
    if(key in menu_def)
	return menu_def[key]
    if(key in class)
	return class[key]
    if(key in attr)
	return attr[key]
    if(key in ctx)
	return ctx[key]
}
# define globally, not overwriting any coming from -a switch
func defAttr(key, value) {
    if(key in attr)
	return
    attr[key] = value
}
func setCtx(key, value) {
    # todo: instead of prepending "ctx." here stripping it from get()'s arg should be clearer
    ctx["ctx",key] = value
}
# define a property for a single record, not copied to menu
func set(key, value) {
    return class[key] = value
}

# define a property for all following menu() calls, stored in menu for @function() calls later 
func def(key, value) {
    menu_def[key] = value
}
func undef(key) {
    delete menu_def[key]
}
# define a property for the *next* menu() call, do not overwrite previous let() calls, stored in menu
func let(key, value) {
    if(menu_let[key] == "")
	menu_let[key] = value
}
