
# archive file types
{ cd(get("file.dirname")) }
get("file.mimetype") ~ /^application\/x-rar/ {
    # -ts- do not preserve date
    menu(xterm_error("unrar x -ts- " Q(get("file.name"))))
}
get("file.mimetype") ~ /^application\/zip/ {
    menu(xterm_error("unzip " Q(get("file.name"))))
}
get("file.mimetype") ~ /^application\/x-gzip/ && tolower(get("file.name")) ~ /\.(tar\.gz|tgz)$/ {
    label("untar"); menu(xterm_error("tar xzf " Q(get("file.name"))))
}
get("file.mimetype") ~ /^application\/x-bzip2/ && tolower(get("file.name")) ~ /\.(tar\.bz2|tbz)$/ {
    label("untar"); menu(xterm_error("tar xjf " Q(get("file.name"))))
}
{ cd() }

# audio files
get("file.mimetype") ~ /^audio\/mpeg/ ||
get("file.mimetype") ~ /^audio\/ogg-vorbis/ {
    run("alsaplayer -e " Q(get("file.name")))
    run("mplayer -quiet " Q(get("file.name")))
}

# video files
get("file.mimetype") ~ /^video\/ogg-theora/ {
    mplayer_args = "-mc 0 "
}

get("file.mimetype") ~ /^video\// ||
get("file.mimetype") ~ /application\/vnd\.rn-realmedia/ {
    run("mplayer -quiet " mplayer_args Q(get("file.name")))
    t = tmpname()
    label("dump ogg"); menu(xterm_error("mplayer -quiet -novideo -ao pcm:fast:file=" Q(t) " " Q(get("file.name")) " && oggenc -b 128 -o " Q(get("file.name") ".ogg") " " Q(t) " ; rm " Q(t)))
}
match(get("file.name"), /\/mnt\/ssh\/[a-z]*@wirsing(\/.*)$/, m) && get("file.mimetype") ~ /^video\// {
    label("mplayer @wirsing"); run("xterm -e ssh tv@wirsing DISPLAY=:0 mplayer -quiet " mplayer_args Q(Q(m[1])))
}

# image files
get("file.mimetype") ~ /image\/gif/ {
    label("surf gif"); run(browser("file://" get("file.name")))
}
get("file.mimetype") ~ /image\/svg/ {
    label("surf svg"); run(browser("file://" get("file.name")))
    run("xsvg " Q(get("file.name")))
}
get("file.mimetype") !~ /image\/svg/ && get("file.mimetype") ~ /image\// {
    run("viewnior " Q(get("file.name")))
    label("imagemagick"); run("display " Q(get("file.name")))
    run("gimp -s " Q(get("file.name")))
    run("nip2 " Q(get("file.name")))
}

# documents
get("file.mimetype") ~ /^application\/pdf/ {
    run("mupdf " Q(get("file.name")))
    run("xpdf -cont -z width " Q(get("file.name")))
}
get("file.mimetype") ~ /^application\/x-dvi/ {
    run("xdvi -expert -keep -s 4 " Q(get("file.name")))
}
get("file.mimetype") ~ /^image\/vnd.djvu/ {
    run("djview " Q(get("file.name")))
}
get("file.mimetype") ~ /^application\/ms-chm/ {
    run("xchm " Q(get("file.name")), "xchm")
}
get("file.mimetype") ~ /^application\/postscript/ ||
get("file.name") ~ /\.ps\.gz$/ {
    run("gv " Q(get("file.name")))
    run("gsview " Q(get("file.name")))
}
# manuals and documentation
get("file.mimetype") ~ /^text\/troff/ {
    run(man(Q(get("file.name"))))
}
get("file.name") ~ /\.info(-[0-9]+)$/ ||
get("file.name") ~ /\/info\// {
    run(info("-f " Q(get("file.name"))))
}
get("file.name") ~ /\/usr\// &&
get("file.mimetype") ~ /^text\// {
    label("less"); run(xterm("less " Q(get("file.name"))))
}

# list files
func selectLine(file, filter) {
    # todo: use nesting
    # todo: decide menu type in port.menu.awk (need to pass filename somehow)
    return "< " Q(file) " " postif(filter, " | ") "req -p menu -f history -a filter_uniq=1 -stdin | req -menu -stdin"
}
get("file.mimetype") ~ /^text\// && get("file.name") == attr["history"] {
    label("select line"); run(selectLine(get("file.name"), "tac"))
}
get("file.mimetype") ~ /^text\// && get("file.name") == attr["bookmarks"] {
    label("select line"); run(selectLine(get("file.name")))
}

# graphviz dot files
get("file.mimetype") ~ /^text\/plain/ && get("file.name") ~ /\.dot$/ {
    run("dot -Tx11 -Grankdir=LR " Q(get("file.name")))
}

# html files
get("file.mimetype") ~ /^text\/html/ ||
get("file.mimetype") ~ /^application\/xml/ {
    label("browser"); run(browser("file://" get("file.name")))
}

# text files
get("file.mimetype") ~ /^text\// {
    label("emacs"); run("emacsclient -n " wrapif("+", get("line"), " ") Q(get("file.name")))
    label("less"); menu(xterm("less " Q(get("file.name"))))
    menu(pager("wc " Q(get("file.name"))))
}


get("file.name") {
    label("attach email"); menu("claws-mail --compose --attach " Q(get("file.name")))
    label("pub reis"); menu(publish(get("file.name"), HOME "/www", "http://192.168.0.216/~rfigura"))
    label("pub wirsing"); menu(publish(get("file.name"), "/home/rfigura/mnt/ssh/rfigura@wirsing/www", "http://wirsing.deinding.net/~rfigura"))
}

# directories
get("directory") {
    run("rox -d " Q(get("directory")))
    let("pwd", get("directory")); run("xterm")
}

!get("directory") && get("file.dirname") {
    label("dir..."); menu(nest(get("file.dirname")))
}

# mercurial
get("hg_status") {
    run(hgtk("commit", get("hg_root")))
}
get("hg_root") {
    run(hgtk("log", get("hg_root")))
}
get("hg_root") && file_mimetype(get("hg_root") "/.hgsub") == "text/plain" {
    label(".hgsub"); run(nest(get("hg_root") "/.hgsub"))
}
get("file.name") ~ /\.hgsub$/ {
    readlist(get("file.name"), 3, " ", get("hg_sub"))
    PROCINFO["sorted_in"] = "@ind_str_asc"
    m = get("hg_sub")
    for(i in m) {
	label("hgsub " i); run(nest(get("file.dirname") "/" i))
    }
}

# mount
!get("mountpoint") && index(get("filelike"), HOME "/mnt") == 1 {
    run(nest(get("filelike"), "mount"))
}
get("mountpoint") {
    menu(nest(get("mountpoint"), "umount"))
}

get("file.name") {
    label("REMOVE FILE"); menu("rm -f " Q(get("file.name")))
}
