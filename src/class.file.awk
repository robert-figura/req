
{
    filename = $0
}
# file:// local filename url style
match(filename, /^file:\/\/(.*)$/, m) {
    filename = urldecode(m[1])
}
# detect line numbers
# gawk error messages
(match(filename, /: (.+):([0-9]+)/, m) ||
# grep style:
 match(filename, /^(.+):([0-9]+)/, m) ||
# php error message:
 match(filename, /^(.+) on line ([0-9]+)/, m) ||
# ocaml error message
 match($0, /^File "(.+)", line ([0-9]+), /, m)) &&
m[2] > 0 {
    filename = m[1]
    set("line", m[2])
}
# bash shortcut for home directory
match(filename, /^~\/(.*)$/, m) {
    filename = HOME "/" m[1]
}
# relative filename?
!(filename ~ /^\//) {
    filename = get("ctx.wdir") "/" filename
}
# absolute filename?
filename ~ /^\// {
    split_file(filename, class)
    set("filelike", filename) # mount
}

{
    set("directory", get("file.directory"))
}

# mount
BEGIN {
    split_mount()
}
filename {
    set("mountpoint", find_mount(filename))
}

# mercurial
get("file.dirname") {
#    set("hg_root", get("file.dirname"))
}
get("hg_root") {
    set("hg_status", btick("hg status -mard -n -S -R " Q(get("hg_root"))))
}

# map ssh file with existing sshfs mount target to file
{ f = p = "" }
# todo: remove?:
func isDir(f) {
    return file_mimetype(f) == "inode/directory"
}
get("ssh.host") && isDir(p = HOME "/mnt/ssh/" postif(get("ssh.user"), "@") get("ssh.host")) {
    set("ssh.mountpoint", p)
    f = p (get("ssh.file") ? get("ssh.file") : "/home/" get("ssh.user"))
    set("ssh.localmimetype", file_mimetype(f))
}
# todo: use some is_mounted() instead of plain get("ssh.file"):
get("ssh.localmimetype") == "inode/directory" && get("ssh.file") {
    set("ssh.localdir", f)
}
get("ssh.localmimetype") {
    set("ssh.localfile", f)
}

# map file below existing mount point to ssh url
match(get("file.name"), /\/mnt\/ssh\/([^@]+)@([^\/]+)(\/?.*)$/, m) {
    # todo: use new variables here, too?:
    set("file_ssh.user", m[1])
    set("file_ssh.host", m[2])
    set("file_ssh.file", m[3])
}

# extend underspecified file_mimetypes:
{
    filetype = ""
}
get("file.mimetype") ~ /^application\/ogg/ ||
get("file.mimetype") ~ /^application\/octet-stream/ {
    filetype = btick("file -b -- "Q(get("file.name")))
}
filetype ~ /Vorbis audio/ {
    set("file.mimetype", "audio/ogg-vorbis")
}
filetype ~ /Audio file/ &&
file_ext(get("file.name")) == "mp3" {
    set("file.mimetype", "audio/mpeg")
}
filetype ~ /^Ogg data, Skeleton/ ||
filetype ~ /Theora video/ {
    set("file.mimetype", "video/ogg-theora")
}
filetype ~ /EBML file, creator matroska/ {
    set("file.mimetype", "video/matroska")
}
filetype ~ /ISO Media/ {
    set("file.mimetype", "video/iso image")
}
filetype ~ /MS Windows HtmlHelp Data/ {
    set("file.mimetype", "application/ms-chm")
}

# executable
# todo: make better patterns, allow full commandlines
# todo: include regex subp for env prefix (maybe also exec, ... keywords)
match($0, /^([a-zA-Z0-9_.\-]+)( .*)?$/, m) {
    # only if bash thinks it is executable
    if(btick("type -p " Q(m[1]) " 2> /dev/null")) {
	set("exe", m[1])
	set("args", m[2])
	set("cmdline", m[1] " " m[2])
    }
}
