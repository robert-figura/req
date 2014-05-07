
get("word") {
    menu(browser("http://dict.cc/?s=" urlencode(get("word"))))
}
w = get("identifier") {
    label("gaze url");         menu("surf \"$(gaze -q url " Q(w) ")\"") # todo: generalize to other browsers
    label("gaze what");        menu(pager("gaze url " Q(w) " ; gaze what " Q(w) " ; gaze source_urls " Q(w)))
    label("gaze search name"); menu(pager("gaze search -name " Q(w)))
    label("gaze search");      menu(pager("gaze search " Q(w)))
}
get("file.name") {
    label("gaze from");        menu(pager("gaze from " Q(get("file.name"))))
}
get("phrase") {
    label("google.com"); menu(browser("https://encrypted.google.com/search?q=" urlencode(get("phrase"))))
    menu(browser("http://en.wikipedia.org/wiki/" urlencode(get("phrase"))))
    menu(browser("http://de.wikipedia.org/wiki/" urlencode(get("phrase"))))
    # todo: allow joining rest of multiline input
    label("translate"); menu(browser("https://translate.google.com/#auto/en/" urlencode(get("phrase"))))

    menu(browser("http://ncatlab.org/nlab/search?query=" urlencode(get("phrase"))))
    
    menu(browser("http://youtube.com/results?search_query=" urlencode(get("phrase"))))
    label("imdb.com"); menu(browser("http://www.imdb.com/find?q=" urlencode(get("phrase")) "&s=all#kw"))
    label("putlocker.com"); menu(browser("https://encrypted.google.com/search?q=" urlencode(get("phrase") " \"www.putlocker.com\"")))
    label("sockshare.com"); menu(browser("https://encrypted.google.com/search?q=" urlencode(get("phrase") " \"www.sockshare.com/file\"")))
}
get("identifier") {
    label("google.com"); menu(browser("https://encrypted.google.com/search?q=" urlencode(get("identifier"))))
    
    let("auto", get("ctx.file.name") ~ /\.php$/ || get("ctx.xprop.url") ~ /:\/\/php\.net/)
    menu(browser("http://php.net/search.php?show=quickref&lang=en&pattern=" urlencode(get("identifier"))))

    let("auto", get("ctx.file.name") ~ /\.java$/)
    label("android.com");
    menu(browser("http://developer.android.com/index.html#q=" urlencode(get("identifier"))))

    let("auto", get("ctx.file.name") ~ /\.awk$/)
    label("info gawk");
    menu(xterm("info gawk --index-search=" Q(get("identifier"))))
}

get("word") || get("identifier") {
    label("info apropos"); menu(pager("info -k " Q(get("word"))))
    label("man apropos"); menu(pager("man -k " Q(get("word"))))
}
get("phrase") {
    menu(pager("recollq " Q(get("phrase"))))
}

# oeis: online encyclopedia of integer sequences
/^[0-9]+[, ]+[0-9]+[, ]+[0-9][0-9, ]*$/ ||
/^A[0-9]+$/ {
    gsub(/  */, ",");
    menu(browser("http://oeis.org/search?q=" urlencode($0) "&language=english&go=Search"))
}
