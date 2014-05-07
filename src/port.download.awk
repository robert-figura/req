
@include "ctx.awk"
@include "class.awk"
@include "class.file.awk"
@include "class.pid.awk"

func download_doit(cmd) {
    runHook(xterm(Q(REQ_DIR "/bin/download") " " Q(get("download_url")) " " cmd))
}
func download(cmd) {
    let("label", "download " word(cmd))
    let("download_url", $0)
    return "@download_doit " cmd
}

# for downloads:
BEGIN {
    defAttr("cookie_file", HOME "/.surf/cookies.txt")
}

func curl(url,    f) {
    f = "-f -J -L -O"
    f = f flag("-b", get("cookie_file"))
    f = f flag("-e", get("referer"))
    f = f flag("-A", get("useragent"))
    return download("curl " f " " Q(url))
}

{ cd("/tmp/rfigura") }
# download video
# todo: use a lookup list instead of hand-written matches:
get("http.domain") ~ /(dailymotion|ted)\.com/ ||
get("http.domain") == "arte.tv" ||
get("http.query") && get("http.domain") ~ /(dailymotion|vimeo|youtube)\.com/ {
    # todo: add --referer support:
    label("download youtube-dl"); run(download(s = "youtube-dl --no-playlist --no-mtime -t " Q($0)))
    label("ssh youtube-dl"); run(download("ssh rfigura@wirsing.deinding.net " s))
}
/^mms:\/\// {
    label("download mplayer"); run(download(s = "mplayer -dumpstream -dumpfile " Q(file_basename($0) "." m[1]) " -playlist " Q($0)))
    label("ssh dl mplayer"); run(download("ssh rfigura@wirsing.deinding.net " s))
}
match(get("http.file"), /\.(asx|smil|ram|mov)$/, m) {
    label("download mplayer"); run(download(s = "mplayer -dumpstream -dumpfile " Q(file_basename(get("http.file")) "." m[1]) " -playlist " Q(get("http.url"))))
    label("ssh dl mplayer"); run(download("ssh rfigura@wirsing.deinding.net " s))
}

{ cd(HOME "/Download") }
get("http.url") ||
get("ftp.url") {
    run(curl($0))
}

{ cd() }
