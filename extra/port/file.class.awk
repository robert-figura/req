
func set_file(f, line, col,    a) {
    if(!(f ~ /^\//))
	f = ctx("wdir") "/" f
    if(!split_file(f, a))
	return 0
    setArray("file", a)
    set("file_line", line)
    set("file_col", col)
    return 1
}

# Splitting files is expensive, as it runs an external process to
# determine filetypes. Hence we do all matches in a single || 'or'
# expression, with the most likely case first.

# simple filename
set_file(expand_tilde($0)) ||
# set_file(expand_tilde(ctx("pwd") $0)) || # todo: need a good ctx("pwd") first
# file:// uri
match($0, /^file:\/\/([^#]*)(#.*)?$/, m) && set_file(urldecode(m[1])) ||
# grep -n format: "file:line:column: ..."
match($0, /^(.*)(:([0-9]+))?(:([0-9]+))?:/, m) && set_file(m[1], m[3], m[5]) ||
# gawk error messages
match($0, /: (.+):([0-9]+)/, m) && set_file(m[1], m[2]) ||
# php error message:
match($0, /^PHP.* in (.+) on line ([0-9]+)/, m) && set_file(m[1], m[2]) ||
match($0, /^(.+) on line ([0-9]+)/, m) && set_file(m[1], m[2]) ||
# ocaml error message
match($0, /[Ff]ile "(.+)", line ([0-9]+), characters ([0-9]+)-([0-9]+)/, m) && set_file(m[1], m[2], m[3]) {
}
