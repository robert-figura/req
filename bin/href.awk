#!/bin/gawk -f

# curl -s http://... | href.awk -v allow=img
# url="http://..." ; curl -s "$url" | href.awk | hnorm.awk -v "url=$url"

func attrdecode(text) {
    # this is xml, html has more...
    gsub(/&apos;/, "'", text)
    gsub(/&quot;/, "\"", text)
    gsub(/&gt;/, ">", text)
    gsub(/&lt;/, "<", text)
    gsub(/&amp;/, "\\&", text)
    return text
}
func attr(name, _i, _m, _n) {
    patsplit($1, _m, "[^ \t\n\r]+")
    for(_i = 2; _i <= length(_m); ++_i) {
	if((match(_m[_i], /^([^=]*)="(.*)"$/, _n) && tolower(_n[1]) == name) ||
	   (match(_m[_i], /^([^=]*)='(.*)'$/, _n) && tolower(_n[1]) == name) ||
	   (match(_m[_i], /^([^=]*)=(.*)$/, _n) && tolower(_n[1]) == name))
	    return attrdecode(_n[2]);
    }
    return ""
}
BEGIN {
    RS = "<"
    FS = "/?>"
    allow = allow ? gensub(/,/, "|", "g", "^"allow"$") : "^a|area$"
}
{
    match($1, /^([^ \t\n\r]*)[ \t\n\r]/, m)
    tag = tolower(m[1])
    cdata = $2
    otag = ctag = ""
}
/^\// { ctag = tag }
!ctag { otag = tag }

# otag { path = gensub(/^\./, "", 1, path "." tag) } # path recorder
################################################################

tag !~ allow { next }

{
    link = ""
}

otag == "a"      { link = attr("href") }
otag == "area"   { link = attr("href") }
otag == "base"   { link = attr("href") }
otag == "embed"  { link = attr("src") }
otag == "form"   { link = attr("action") }
otag == "frame"  { link = attr("src") }
otag == "iframe" { link = attr("src") }
otag == "img"    { link = attr("src") }
otag == "layer"  { link = attr("src") }
otag == "link"   { link = attr("href") }
otag == "object" { link = attr("data") }
otag == "param"  { link = attr("value") }
otag == "script" { link = attr("src") }

link {
    print link
}

################################################################
# ctag { path = substr(path, 0, length(path)-length(tag)-1) } # path recorder
