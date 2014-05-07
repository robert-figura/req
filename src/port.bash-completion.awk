
# to enable put this into your .bashrc:
# complete -o default -C 'req -p bash-completion -alias' -D

{
    exe = $1
    part = $2
    prev = $3
}
prev == exe {
    prev = ""
}

func filtertick(prefix, cmd, i, fs,    nf, a, b, k) {
    if(!fs)
	fs = " "
    if(!i)
	i = 1
    split(btick(cmd), a, "\n")
    for(nf in a) {
	split(trim(a[nf]), b, fs)
	if(b[i] && index(b[i], prefix) == 1)
	    ret = ret (k++ ? "\n" : "") b[i]
    }
    return ret
}

# todo: enable completion types in a first step and print them in the next?
# /^ssh / { comptypes["favhost"]++ }
# # later on:
# comptypes["favhost"] { ... }

func max(x, y) {
    return x > y ? x : y
}
func compAdd(str) {
    if(str !~ /^[a-zA-Z0-9/._\-]*$/)
	str = Q(str)
    print str
}

# command switch
part ~ /^-/ {
    compAdd(filtertick(part, "GROFF_NO_SGR=1 man " Q(exe) " | col -bp 2> /dev/null"))
    next
}

# ssh
exe == "ssh" {
    readlist(attr["favorites"], 1, " ", fav)
    for(k in fav)
	if(match(k, /^ssh:\/\/(([^@]*)@)?([^:\/]*)(:[0-9]*)?(\/(\/?.*))?$/, m))
	    if(index(postif(m[2], "@") m[3],$2) == 1)
		compAdd(wrapif("-p ", m[4], " ") postif(m[2], "@") m[3])
}

# host
exe == "ping" {
    readlist(attr["favorites"], 1, " ", fav)
    for(k in fav)
	if(match(k, /^(https?|ssh):\/\/(([^@]*)@)?([^:\/]*)(:[0-9]*)?(\/(\/?.*))?$/, m))
	    if(index(m[4], part) == 1)
		compAdd(m[4])
	
}

exe ~ /^(cast|dispel)$/ {
    compAdd(filtertick($2, "gaze search -name " Q("^" $2), 3))
}

# default completion comes in when no matches are printed
