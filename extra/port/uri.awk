
get("vnc_host") {
    auto(1); menu("vncviewer " Q(get("vnc_host")) wrapQ("::", get("vnc_port")))
}
get("ftp") {
    menu(dl_curl(get("ftp")))
}

get("uri_proto") == "rtsp" ||
get("uri_proto") == "mms" ||
get("http_path") ~ /\.(mp3|ogg)$/ ||
get("http_path") ~ /\.(mp4|asx|smil|ram|mov|wmv|flv|webm|ogv)$/ {
    auto(1); menu(mpv(get("uri"), "--no-ytdl"))
    menu(dl_mpv(get("uri")))
}

get("http_path") ~ /\.(tgz|tbz2|gz|bz2|rar|zip|pdf)$/ ||
prefix_in(get("uri"), "\
http://arxiv.org/pdf/ \
http://arxiv.org/ps/ \
") {
    auto(1); menu(dl_curl(get("http")))
}

#prefix_in(get("http_domain"), "\
#soundcloud.com \
#ted.com \
#vimeo.com \
#") ||
#get("http_domain") == "youtube.com" && get("uri_arg_v") {
#    auto(1); menu(mpv(get("http"), "--ytdl"))
#    menu(dl_youtube(get("http")))
#}

@include "browser.awk"

get("http") {
    menu(dl_curl(get("http")))
}

match(get("uri_path"), /^(.*)\/([^/]+)\/?$/, m) {
    label("uri parent dir..."); menu(req("", "", uri_cd("uri", m[1])))
}

get("urlencoded") {
    label("urldecode"); menu(req("", "", urldecode(get("urlencoded"))))
}
/[^/a-zA-Z0-9_.~-]/ {
    label("urlencode"); menu(req("", "", urlencode($0)))
}
