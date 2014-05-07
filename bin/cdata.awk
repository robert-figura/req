#!/bin/gawk -f

func trim(s) {
    return gensub(/^[ \t\n\r]*(.*)[ \t\n\r]$/, "\\1", 1, s);
}
func attrdecode(text) {
    # this is xml, html has more...
    gsub("&apos;", "'", text)
    gsub("&quot;", "\"", text)
    gsub("&gt;", ">", text)
    gsub("&lt;", "<", text)
    gsub("&amp;", "\\&", text)
    return text
}
func attr(name, _i, _m, _n) {
    patsplit($1, _m, "[^ \t\n\r]+")
    for(_i = 2; _i < length(_m); ++_i)
	if((match(_m[_i], /^([^=]*)="(.*)"$/, _n) && tolower(_n[1]) == name) ||
	   (match(_m[_i], /^([^=]*)='(.*)'$/, _n) && tolower(_n[1]) == name) ||
	   (match(_m[_i], /^([^=]*)=(.*)$/, _n) && tolower(_n[1]) == name))
	    return attrdecode(_n[2]);
    return ""
}
BEGIN {
    RS = "<"
    FS = "/?>"
    allow = allow ? gensub(/,/, "|", "g", "^"allow"$") : "^title$"
}
{
    tag = tolower(trim($1))
    cdata = $2
    otag = ctag = ""
}
/^\// { ctag = tag }
!ctag { otag = tag }

# otag { path = gensub(/^\./, "", 1, path "." tag) } # path recorder
################################################################

otag ~ allow {
    print cdata
}

################################################################
# ctag { path = substr(path, 0, length(path)-length(tag)-1) } # path recorder
