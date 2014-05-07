
@include "lib.api.awk"
@include "lib.string.awk"
@include "lib.shell.awk"
@include "lib.menu.awk"
@include "lib.ns.awk"
@include "lib.file.awk"
@include "lib.wrappers.awk"

BEGIN {
    RS = "\n"
    FS = "[ ]*"
    SUBSEP = "."
    
    REQ_DIR = realpath(ENVIRON["REQ_DIR"])
    REQ_VERSION = ENVIRON["REQ_VERSION"]
    REQ_VERBOSE = ENVIRON["REQ_VERBOSE"]

    HOME = realpath(ENVIRON["HOME"])
    TEMP = realpath(ENVIRON["TEMP"])
    if(!TEMP)
	TEMP = REQ_DIR "/tmp"
    
    # defaults
    defAttr("port", "open") # note: the req shell front end uses it's copy to select a port.foo.awk file
    defAttr("from", "shell")
    defAttr("run_hook", "exec")
    defAttr("run_per_record", 1)
    defAttr("filter_percent", 0)
    defAttr("filter_skip_empty", 1)
    defAttr("filter_trim", 1)

    defAttr("favorites", REQ_DIR "/favorites")
    defAttr("bookmarks", REQ_DIR "/bookmarks")
    defAttr("history", TEMP "/history")
    
    verbose("level: " ENVIRON["REQ_LEVEL"])
}

{
    delete class
}

# gawk -v header=<file> ...
BEGIN {
    if(header) {
	readHeader(header)
	++tmpfiles[header]
	header = ""
    }
}
# gawk -v rmfile=<file> ...
BEGIN {
    if(rmfile) {
      # todo: split() rmfile to remove multiple files on cleanup()?
      ++tmpfiles[rmfile]
      rmfile = ""
  }
}

# todo: this is a hack, maybe use attr["FS"] directly instead:
{
    if(attr["format"] == "alias") {
	FS = "\001"
	$0 = "" $0
    }
}

# filter features:
attr["filter_trim"] {
    $0 = trim($0)
}

attr["filter_skip_empty"] && $0 == "" ||
attr["filter_uniq"] && filter_uniq[$0]++ {
    --NR; --FNR # todo: really?
    next
}

attr["filter_percent"] && /%[a-zA-Z_.]+/ {
    while(match($0, /%([a-zA-Z_.]+)/, m))
	gsub("%"m[1], get("ctx."m[1]))
}

# merge multiline feature
attr["filter_merge"] {
    p = attr["filter_merge_prefix"]
    $0 =  (p ? p "\n" : "") collapse(s $0)
}
