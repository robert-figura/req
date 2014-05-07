
length() < 10 ||
attr["from"] == "history" ||
attr["from"] == "bookmarks" ||
inlist(attr["favorites"], $0, 0, " # ") {
    # todo: this doesn't work for multiline records:
    ++no_history
}

!no_history {
    history()
}
