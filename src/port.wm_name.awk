
@include "ctx.awk"

# todo: find a better way:
get("ctx.xprop.wm_class_name") == "Hgtk" ||
get("ctx.xprop.wm_class_name") == "Rox" {
    $0 = get("ctx.file.name")
}
get("ctx.xprop.wm_class_name") == "Surf" {
    $0 = get("ctx.xprop.url")
}

@include "class.awk"

function enter(strs) {
    return xterm("enter -w " strs)
}

function listprefix(f, url, m,    l, rt) {
    if(!url)
	return ""
    if(!lp_cache[f][-1]) {
	rt = RT
	while((getline l < f) > 0)
	    lp_cache[f][i++] = l
	RT = rt
	lp_cache[f][0] = i
	lp_cache[f][-1]++
    }
    for(i = 0; i < lp_cache[f][0]; ++i) {
	l = lp_cache[f][i]
	match(l, /^ *([^# ][^ ]*)( +([^#]+))?( +#(.*))?$/, m)
	if(!m[1])
	    continue
	if(index(m[1], url) != 1)
	    continue
	if(m[3])
	    label("enter " m[3])
	if(m[2])
	    return enter(m[2])
	match(m[1], /^(https?:\/\/)?([^/]+)(\/.*)?$/, m)
	return enter(m[2])
    }
    return ""
}

match(get("ctx.xprop.url"), /^https?:\/\/([^\/]*)/, m) {
    xprop_url_host = m[1]
}

# avoid having passwords in this file:
(e = listprefix(HOME "/.enter", $1)) ||
(e = listprefix(HOME "/.enter", get("ctx.xprop.url"))) {
    run(e)
}
xprop_url_host == "facebook.com" {
    run(enter(Q(xprop_url_host)))
}
xprop_url_host == "plus.google.com" ||
xprop_url_host == "accounts.google.com" {
    run(enter("plus.google.com"))
}

# offer to open documentation
get("ctx.xprop.wm_name") == "gp" {
    run("xdvi " Q("/usr/share/doc/pari/doc/users.dvi"))
    menu(man("gp"))
}

@include "port.open.awk"
