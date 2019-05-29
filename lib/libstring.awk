
func trim(s) {
    s = gensub(/^[ \t\n\r]*/, "", 1, s)
    s = gensub(/[ \t\n\r]*$/, "", 1, s)
    return s
}
func lpad(s, n, c,    i) {
    if(!("" c))
	c = " "
    for(i = length(s); i < n; ++i)
	s = c s
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
func crop(s, k, p,    n) {
    if(!sep)
	sep = "..."
    n = length(s)
    k = k - length(sep) / 2
    return n <= k ? s : substr(s, 1, k) sep substr(s, n - k)
}
func coalesce(s1, s2, s3) {
    if("" s1)
	return s1
    if("" s2)
	return s2
    if("" s3)
	return s3
    return ""
}

# ord[c] converts characters to codes
BEGIN {
    for(i = 0; i <= 255; ++i)
	ord[sprintf("%c", i)] = i
}

func hex_digit(n, i) {
    return substr("0123456789abcdef", and(rshift(n, i), 0xf)+1, 1)
}
func hex(n) {
    return hex_digit(n, 4) hex_digit(n, 0)
}
func hex16(n) {
    return hex_digit(n, 12) hex_digit(n, 8) hex_digit(n, 4) hex_digit(n, 0)
}

func wrap(pre, s, post) {
    return "" s ? pre s post : ""
}

func is_in(q, s, sep,    m) {
    if(!sep)
	sep = " "
    split(s, m, sep)
    for(i in m)
	if(m[i] == q)
	    return 1
    return 0
}
func prefix_in(q, s, sep,    m) {
    if(!sep)
	sep = " "
    split(s, m, sep)
    for(i in m)
	if(index(q, m[i]) == 1)
	    return 1
    return 0
}

# shell escaping
func Q(s) {
    if(s ~ /^[/a-zA-Z0-9.,:_=%@+-]+$/) # only allowed characters
	return s
    # quote ' -> '\'', and enclose in '
    return "'" gensub(/'/, "'\\\\''", "g", s) "'"
}
func wrapQ(pre, s, post) {
    return "" s ? pre Q(s) post : ""
}

# network stuff
func urldecode(text,    m, i, ret) {
    split(text, m, "%")
    ret = m[1]
    for(i = 2; i <= length(m); ++i)
	ret = ret sprintf("%c", strtonum("0x" substr(m[i], 0, 2))) substr(m[i], 3)
    return ret
}
func urlencode(s,    a, ret) {
    split(s, a, "")
    for(i = 1; i <= length(a); ++i)
	if(a[i] ~ /^[/a-zA-Z0-9_.~-]$/) # allowed
	    ret = ret a[i]
	else
	    ret = ret "%" hex(ord[a[i]])
    return ret
}
func match_domain(host,    m) {
    return match(host, /^([-a-zA-Z0-9]+\.)*([0-9a-zA-Z-]+\.[a-zA-Z-]+)$/, m) ? m[2] : host
}
func match_host(host,    m) {
    return match(host, /^([-a-zA-Z0-9]+\.)*([0-9a-zA-Z-]+\.[a-zA-Z-]+)$/, m) ? "" : host
}
func match_uri(url,     m) {
    # won't recognize hostless uri: neither 'file:///foobar', nor 'about:config'!
    #   12              34     5 6          7     8 9         a        b  c        d e
    # /^((https?):\/\/)?((USER)(:(PASS))?@)?(HOST)(:(DIGITS))?(\/PATH)?(\?(QUERY))?(#(FRAGMENT))?$/
    return match(url, /^(([a-z]*):\/\/)?(([^:@]+)(:([^@]+))?@)?([-a-zA-Z0-9.]+)(:([0-9]+))?(\/[^?#]*)?(\?([^#]*))?(#(.*))?$/, m);
}
