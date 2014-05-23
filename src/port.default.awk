
# copy data to x11 selection
$0 != get("ctx.sel") {
    label("SELECT"); menu("@xsel " $0)
}
# copy data to x11 clipboard
{
    label("COPY"); menu("echo -n " Q($0) " | xclip -i -selection clipboard")
}

# bookmarks, usually hand picked lines from history
attr["from"] != "bookmarks" {
    label("BOOKMARK"); menu("@bookmark " $0)
}
attr["from"] == "bookmarks" {
    label("FORGET"); menu("@forget " $0)
}

# multiline features
func pick_line(s) {
    s = collapse(s)
    c = btick(nest(s, "menu"))
    runHook(nest(trim(c)))
}
# this is a hack to reclassify full line, see main.head.awk:
func merge_lines(s) {
    attr["filter_merge"] = 1
    attr["filter_merge_prefix"] = s
}
# todo: remove NR==1 check? allow mergeing late?
NR == 1 && RT {
    label("PICK LINE"); menu("@pick_line " $0)
    label("MERGE LINES"); menu("@merge_lines " $0)
}
# cancel multiline
RT || NR > 1 {
    label("CANCEL"); menu("@quit 1")
}

# debug
{
    label("DUMP"); menu("@dump")
    label("DUMP MENU"); menu("@dumpMenu")
}
