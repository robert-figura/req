
# choice
func choice(key) {
    return choice_map[cid "." key];
}
func setChoice(key, value) {
    choice_map[cid "." key] = value;
}
func defChoice(key, value) {
    key = cid "." key
    if(key in choice_map)
	return
    choice_map[key] = value;
}
BEGIN {
    deleteChoices()
}
func newChoice(    i) {
    nchoices = cid
    ++cid
}
func deleteChoices() {
    cid = 1
    nchoices = 0
    delete choice_map;
}

# class
func class(key) {
    return class_map[key];
}
func setClass(key, value) {
    class_map[key] = value;
}
func deleteClass() {
    delete class_map;
}
func printClass(    i) {
    printf "%s", a2s(class_map)
}

# arg
func arg(key) {
    return arg_map[key];
}
func setArg(key, value) {
    arg_map[key] = value;
}
func readArgs(file) {
    file_get_map(file, arg_map)
}

# ctx
func ctx(key) {
    return ctx_map[key];
}
func setCtx(key, value) {
    ctx_map[key] = value;
}
func readCtx(file) {
    file_get_map(file, ctx_map)
}
func printCtx() {
    printf "%s", a2s(ctx_map)
}

# array utilities
func a2s(a, sep,    p, i, r) {
    if(!sep)
	sep = "="
    p = PROCINFO["sorted_in"]
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for(i in a)
	if(a[i] != "") # skip empty
	    r = r i sep a[i] "\n"
    PROCINFO["sorted_in"] = p
    return r
}
func keys(a, sep,    k, r) {
    if(!("" sep))
	sep = " "
    for(k in a)
	r = r sep k
    return substr(r, 1+length(sep))
}
func dump2string(    r) {
    r =   "record:\n" $0 "\n"
    r = r "\narg:\n" a2s(arg_map, " = ")
    r = r "\nctx:\n" a2s(ctx_map, " = ")
    r = r "\nclass:\n" a2s(class_map, " = ")
    r = r "\nis_a: " keys(is_a) "\n"
    r = r "\nchoice:\n" a2s(choice_map, " = ")
    return r
}
