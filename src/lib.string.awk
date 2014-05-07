
# form lib.awk:
func trim(s) {
    s = gensub(/^[ \t\n\r]*/, "", 1, s)
    s = gensub(/[ \t\n\r]*$/, "", 1, s)
    return s
}
func word(str, i, fs,    m) {
    if(!fs)
	fs = " "
    split(str, m, fs)
    if(i < 0)
	i = length(m)+i+1
    return m[i ? i : 1]
}

# argument utilities:
func wrapif(pre, s, post) {
    return s ? pre s post : ""
}
func postif(s, p) {
    return s ? s p : ""
}
func preif(p, s) {
    return s ? p s : ""
}
func flag(sw, value) {
    return value ? (" " sw " " Q(value)) : ""
}
function files(f1, f2, f3, f4, f5,   c) {
    c = " "
    if(f1) c = c Q(f1) " "
    if(f2) c = c Q(f2) " "
    if(f3) c = c Q(f3) " "
    if(f4) c = c Q(f4) " "
    if(f5) c = c Q(f5) " "
    return c
}
