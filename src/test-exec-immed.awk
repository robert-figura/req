
END {
    print "END" # <- should not appear
}

{
    print "{" # <- this line may not make it if there is no fflush(NULL) call before execl(...)
    exec("echo success")
    exit 1 # exec has failed
    print "}" # <- unreachable
}
