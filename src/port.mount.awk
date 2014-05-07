
BEGIN {
    split_mount()
    defAttr("retry", attr["via"])
    attr["run_per_record"] = 0
}

/^\// {
    file = $0
}
match($0, /^~\/(.*)$/, m) {
    file = HOME "/" m[1]
}
!file {
    file = get("ctx.wdir") "/" $0
}

attr["retry"] {
    open_cmd = " && " nest(file, attr["retry"])
}

BEGIN {
#    sshfs_opts = postif(sshfs_opts, ",") "no_check_root"
    sshfs_opts = postif(sshfs_opts, ",") "reconnect"
#    sshfs_opts = postif(sshfs_opts, ",") "delay_connect"
    sshfs_opts = postif(sshfs_opts, ",") "intr"
    if(sshfs_opts)
	sshfs_flags = sshfs_flags flag("-o", sshfs_opts)
}
index(file, target = HOME "/mnt/ssh/") == 1 &&
match(substr(file, length(target)), /^\/([^/:]+)(:([0-9]+))?/, m) {
    target = target m[1] preif(":", m[3])
    sshfs_flags = sshfs_flags preif(" -p ", m[3])
    run(mount("sshfs " sshfs_flags " " Q(m[1] ":/"), target) open_cmd)
}

index(file, target = HOME "/mnt/crypt") == 1 {
    run(mount("encfs -i 2 " Q(HOME "/mnt/.crypt"), target) open_cmd)
}

index(file, target = HOME "/mnt/ftp") == 1 &&
match(file, /\/ftp\/(([^@/]*)@)?([^/]*)/, m) {
    run(mount("curlftpfs -o user=" Q(m[2]) " " Q(m[3]) " " Q(target)))
}
