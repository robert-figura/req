
BEGIN {
    split_mount()
    attr["run_per_record"] = 0
}

{ 
    target = find_mount($0)
}

target && get("ctx.mount."target".type") ~ /^fuse/ {
    label("umount " target); run(umount("fusermount -u", target))
}
