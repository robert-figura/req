
# from port.http.awk
get("http.url") {
    label("http headers"); menu(pager("curl -s -I " Q(get("http.url"))))
    label("html links"); menu(pager(REQ_DIR "/bin/curlink.sh -a embed,object,a,area " Q(get("http.url"))))
    label("html img links"); menu(pager(REQ_DIR "/bin/curlink.sh -a img " Q(get("http.url"))))
    label("html label (sel)"); menu("curl -s " Q(get("http.url")) " | " REQ_DIR "/bin/cdata.awk | " REQ_DIR "/bin/trim.awk | xclip -i")
}
get("host") {
    menu(xterm("ping " Q(get("host"))))
    menu(pager("nmap " Q(get("host"))))
    menu(pager("traceroute " Q(get("host"))))
    menu(pager("arp " Q(get("host"))))
}
get("host") && !get("ip") {
    label("dns"); menu(pager("dig " Q(get("host"))))
    # todo: generalize feature to paste calculator results to x11 selection:
    label("ip (sel)"); menu("dig +short " Q(get("host")) " | " REQ_DIR "/bin/trim.awk | xclip -i")
}
get("ip") {
    label("reverse-dns"); menu(pager("dig -x " Q(get("ip"))))
}
get("domain") {
    menu(pager("whois -T dn " Q(get("domain"))))
}

# from port.file.awk:
get("file.mimetype") ~ /^text\/html/ ||
get("file.mimetype") ~ /^application\/xml/ {
    label("html links"); menu(pager(REQ_DIR "href.awk " Q(get("file.name")) " | " REQ_DIR "hnorm.awk"))
}
get("file.mimetype") ~ /^application\/zip/ {
    export("xterm_title", "zip " file); label("list zip"); run(pager("unzip -vb " Q(get("file.name"))))
}
get("file.mimetype") ~ /^application\/x-gzip/ && tolower(get("file.name")) ~ /\.(tar\.gz|tgz)$/ {
    export("xterm_title", "tar " get("file.name")); label("list tar"); run(pager("tar tzf " Q(get("file.name"))))
}
get("file.mimetype") ~ /^application\/x-bzip2/ && tolower(get("file.name")) ~ /\.(tar\.bz2|tbz)$/ {
    export("xterm_title", "tar " get("file.name")); label("list tar"); run(pager("tar tjf " Q(get("file.name"))))
}
get("file.mimetype") ~ /application\/x-executable/ ||
get("file.mimetype") ~ /application\/x-sharedlib/ {
    menu(pager("ldd " Q($0)))
    menu(pager("readelf -s " Q($0)))
    menu(pager("nm " Q($0)))
    menu(pager("strings " Q($0)))
}
get("file.mimetype") ~ /^application\/pdf/ ||
get("file.mimetype") ~ /^audio\// ||
get("file.mimetype") ~ /^image\// ||
get("file.mimetype") ~ /^video\// {
    label("metainfo"); menu(pager("exiftool -g " Q(get("file.name"))))
}
get("file.name") {
    menu(pager("stat " Q(get("file.name"))))
}
get("directory") {
    menu("filelight " Q(get("directory")))
}
