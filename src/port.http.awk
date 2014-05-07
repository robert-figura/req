
# surf customization:
# for downloads:
!get("cookie_file") {
    def("cookie_file", HOME "/.surf/cookies.txt")
}
# no script
get("http.domain") ~ /^(feedsportal|zerohedge)\.com$/ ||
get("http.domain") ~ /^(heise|tvinfo|zeit|taz)\.de$/ {
    def("surf_flags", "-p -s")
}
# cookie jail
get("http.domain") == "github.com" ||
get("http.domain") == "wordpress.com" ||
get("http.domain") == "facebook.com" {
    def("cookie_file", HOME "/.surf/cookies." get("domain") ".txt")
}
get("host") == "meine.deutsche-bank.de" {
    def("cookie_file", HOME "/.surf/cookies." get("host") ".txt")
}
get("host") == "www.circlecount.com" ||
get("host") == "selectedpapers.net" ||
get("host") == "plus.google.com" {
    def("cookie_file", HOME "/.surf/cookies.accounts.google.com.txt")
}


# protect against redirections
get("http.domain") == "google.com" && get("http.path") == "/url" && get("http.args.q") {
    label("surf (protected)"); run(browser(get("http.args.q")))
    # todo: improve:
    label("(protected)..."); menu(nest(get("http.args.q")))
}
get("http.domain") == "google.com" && get("http.path") == "/imgres" {
    label("surf (protected)"); run(browser(get("http.args.imgrefurl")))
    label("surf (image)"); menu(browser(get("http.args.imgurl")))
}
get("http.domain") == "facebook.com" && get("http.args.redirect_uri") {
    # todo: remove facebook app references from link
    label("surf (protected)"); run(browser(get("http.args.redirect_uri")))
    label("(protected)..."); menu(nest(get("http.args.redirect_uri")))
}
func decrypt_goo_gl(url,    s, m) {
    s = btick("curl -s " Q(url))
    match(s, /document has moved <A HREF="([^"]*)">here<\/A>/, m)
    runHook(nest(m[1]))
}
get("http.domain") == "goo.gl" && get("http.path") {
    label("(decrypted)..."); run("@decrypt_goo_gl " get("http.url"))
}

# download

get("http.url") ~ /\.torrent$/ {
    run(xterm("rtorrent -d ~/Download/ " Q(get("http.url"))))
}
tolower(get("http.file")) ~ /\.(mp3|ogg|mov|djvu|pdf|zip|tgz|tar\.(gz|bz2))/ ||
tolower(get("http.file")) ~ /\.(asx|smil|ram|mp4|mpg)$/ ||
get("http.url") ~ /http:\/\/arxiv.org\/(pdf|ps)\// ||
get("http.domain") == "dailymotion.com" ||
get("http.query") && get("http.domain") ~ /(dailymotion|vimeo|youtube)\.com/ ||
/^http:\/\/blip.tv\/play\// ||
/^http:\/\/videos\.arte\.tv\/de\/videos\/.*\.html/ ||
/^http:\/\/online\.kitp\.ucsb\.edu\/online\/.*\/rm\/flash.*\.html$/ {
    label("download..."); run(nest(get("http.url"), "download"))
}

get("http.domain") == "youtube.com" && get("http.args.list") {
    label("youtube playlist"); menu(pager(REQ_DIR "/bin/curlink.sh -a a " Q("http://www.youtube.com/playlist?list=" get("http.args.list")) " | grep feature=plpp_video"))
}

get("http.url") {
    label("surf"); run(browser(get("http.url")))
    label("tidy errors"); menu(pager("curl -s " Q(get("http.url")) " | tidy -e 2>&1"))
    label("tidy html"); menu(pager("curl -s " Q(get("http.url")) " | tidy -i -u -q 2> /dev/null"))
}
get("hostport") {
    label("surf host"); menu(browser(get("hostport")))
}
