
get("phrase") { # todo: allow joining rest of multiline input
    label("translate");
    menu(websearch("https://translate.google.com/#auto/en/", get("phrase")))
    
    label("google.com"); menu(websearch("https://encrypted.google.com/search?q=", get("phrase")))
    menu(websearch("https://en.wikipedia.org/wiki/", get("phrase")))
}

# series episode calculator
# http://...season-1-episode-2#...
match(get("http"), /^(.*season-)([0-9]+)(-episode-)([0-9]+)(#.*)$/, m) {
    label("next episode"); menu(websearch(m[1] m[2] m[3] (m[4]+1)))
    label("next season");  menu(websearch(m[1] (m[2]+1) m[3] "1"))
}
# http://...s01e01
match(get("http"), /^(.*[Ss])([0-9]+)([eE])([0-9]+)$/, m) {
    label("next episode"); menu(websearch(m[1] m[2] m[3] lpad(m[4]+1, 2, "0")))
    label("next season");  menu(websearch(m[1] lpad(m[2]+1, 2, "0") m[3] "01"))
}

get("identifier") {
    label("google.com"); menu(websearch("https://encrypted.google.com/search?q=", get("identifier")))

    # gawk
    label("info gawk");
    let("auto", ctx("file_name") ~ /\.awk$/)
    menu(info("gawk --index-search=" Q(get("identifier"))))
}

get("word") || get("identifier") {
    label("info apropos"); menu(pager("info -k " Q(get("word"))))
    label("man apropos"); menu(pager("man -k " Q(get("word"))))
}
# man page
match($0, /^([A-Za-z0-9._-]+) ?(\[[^\]]+\] )?\(([0-9]+)\)/, m) {
    auto(1); menu(man(Q(m[3]) " " Q(m[1])))
}
# info page
match($0, /^"?(\([a-zA-Z0-9._-]+\))(([^"]*)")?/, m) {
    auto(1); menu(info(Q(m[1]m[3])))
}
