
# this file is read after port.*.awk:

attr["run_per_record"] {
    doIt()
}
END {
    doIt()
    cleanup()
}
