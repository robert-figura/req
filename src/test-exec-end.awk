
END {
    print "END" # <- if everything works this should be printed
}

{
    print "{" # <- this line may not make it if there is no fflush(NULL) call before execl(...)
    exec("echo success", 1)
    exit 123 # <- the number is irrelevant. How to emulate this call from within the extension?
    print "}" # <- unreachable
}
