
@include "libstring.awk"
@include "libns.awk"
@include "libchoice.awk"
@include "libfile.awk"
@include "libshell.awk"

# api
func def(k, v) {
    if(!(k in class_map))
	setClass(k, v)
}
func set(k, v) {
    setClass(k, v)
    if(v == $0)
	is_a[k]++
}
func setArray(p, a,    i) {
    if("" p)
	p = p "_"
    for(i in a)
	set(p i, a[i])
}
func let(k, v) {
    defChoice(k, v)
}
func get(key,    c) {
    c = cid "." key
    if(c in choice_map)
	return choice_map[c];
    if(key in class_map)
	return class_map[key];
    if(key in arg_map)
	return arg_map[key];
}
# don't need a per-choice inherit? as we can write down these arguments explicitly...
func inherit(k, v) {
    if(!("" v))
	v = arg(k)
    inherit_map[k] = v
}
func req(p, args, s,    a, i, j) {
    if(!p)
	p = get("port")
    if(!s)
	s = $0
    tmp_keep(ENVIRON["REQ_CTX_FILE"])
    label(p "...")
    split(arg("inherit"), i)
    for(j in inherit_map)
	if("" inherit_map[j])
	    a = a " -a " Q(j) " " Q(inherit_map[j])
    return REQ_DIR "/bin/req -p " Q(p) a wrap(" ", args) wrapQ(" -- ", s)
}

# shortcuts
func label(s) {
    defChoice("label", s)
}
func auto(s) {
    defChoice("auto", s)
}
func menu(s) {
    label(word(s, 1))
    setChoice("cmd", s)
    newChoice()
}
func call(f, a) {
    label("@" f)
    setChoice("run", "call")
    setChoice("cmd", "@" f " " a)
    setChoice("call_cmd", f)
    setChoice("call_arg", a)
    newChoice()
}

BEGIN {
    REQ_DIR = ENVIRON["REQ_DIR"]
    HOME = ENVIRON["HOME"]
    TEMP = ENVIRON["TEMP"]
    SHELL = ENVIRON["SHELL"]

    readCtx(ENVIRON["REQ_CTX_FILE"])

    setArg("mode", "run") # run test list class ctx

    readArgs(REQ_DIR "/req.conf")
    readArgs(ENVIRON["REQ_ARG_FILE"])

    tmp_file(ENVIRON["REQ_CTX_FILE"])
    tmp_file(ENVIRON["REQ_ARG_FILE"])
    tmp_file(ENVIRON["REQ_DATA_FILE"])

    if(ENVIRON["REQ_LEVEL"] > 15) {
	print "abort: too much nesting"
	exit 1
    }
    export("REQ_LEVEL", 1 + ENVIRON["REQ_LEVEL"])

    inherit("no_auto")

    if(get("mode") == "ctx") {
	print ctx(get("prop"))
	exit(0)
    }
}

END {
    tmp_cleanup()
    fd_close_all()
}

# filters
0+get("filter_percent") && match($0, /^([^%]*)%([a-zA-Z0-9_]+)(.*)$/, m) {
    $0 = m[1] ctx(m[2])
    s = m[3]
    while(s && match(s, /^([^%]*)%([a-zA-Z0-9_]+)(.*)$/, m)) {
	$0 = $0 m[1] ctx(m[2])
	s = m[3]
    }
    $0 = $0 s
}
0+get("filter_trim") {
    $0 = trim($0)
}
0+get("filter_strip_comment") && match($0, /^(.*) # /, m) {
    $0 = m[1]
}
0+get("filter_skip_comment") && /^[ ]*#/ ||
0+get("filter_skip_empty") && /^$/ ||
0+get("filter_uniq") && filter_uniq[$0]++ {
    --NR
    next
}

# limit max number of records
arg("max_nr") > 0 && NR > arg("max_nr") {
    exit(0)
}
# default menu prompt
!get("menu_prompt") {
    set("menu_prompt", 0+arg("menu_crop") ? crop($0, 33) : $0)
    delete is_a["menu_prompt"]
}

# called by bin/req after all other code blocks:
func at_last() {
    choose()
    deleteClass()
    delete is_a
}
