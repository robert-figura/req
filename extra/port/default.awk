
func bookmark(s) {
    system("echo " Q(s) " >> " Q(get("bookmarks")))
}
func forget(s) {
    tmp = tmp_name("bookmarks")
    system("grep -v -x -F " Q(s) " " Q(get("bookmarks")) " > " Q(tmp) " ; mv " Q(tmp) " " Q(get("bookmarks")))
}
# since we can't call a builtin via call("exit"):
func quit() {
    exit(0)
}

$0 != ctx("xsel") {
    label("SELECT"); menu("echo " Q($0) " | xclip -i")
}

{
    label("BOOKMARK"); call("bookmark")
    label("FORGET"); call("forget")
    label("DUMP"); call("dump")
    label("CANCEL"); call("quit")
}
