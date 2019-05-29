
@include "file.class.awk"

# special files
prefix_in(get("file_name"), "\
/proc/ \
/sys/ \
") {
    label("less"); auto(1); menu(xterm("less " Q(get("file_name"))))
}

# manuals and documentation
get("file_mimetype") == "text/troff" {
    auto(1); menu(man(Q(get("file_name"))))
}
get("file_name") ~ /\.info(-[0-9]+)$/ ||
get("file_name") ~ /\/info\// {
    auto(1); menu(info("-f " Q(get("file_name"))))
}

# graphviz' dot files
get("file_mimetype") == "text/plain" && get("file_ext") ~ /\.dot$/ {
    auto(1); menu("dot -Tx11 -Grankdir=LR " Q(get("file_name")))
}

# any text file
get("file_mimetype") ~ /^text\// {
    auto(get("file_name") ~ /^\/usr\/share\//); menu(xterm("less " Q(get("file_name"))))
    auto(1); menu(emacsclient(get("file_name"), get("file_line")))
    menu(pager("wc " Q(get("file_name"))))

}

!get("file_directory") && get("file_dirname") {
    label("directory..."); menu(req("", "", get("file_dirname")))
}
# directories
get("file_directory") {
    auto(1); let("pwd", get("file_directory")); menu("xterm")
}
get("file_directory") != "/" && get("file_directory") {
    label("parent dir..."); menu(req("", "", file_dirname(get("file_dirname"))))
}
