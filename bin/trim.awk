#!/bin/gawk -f

func trim(s) {
    return gensub(/^[ \t\n\r]*(.*)[ \t\n\r]$/, "\\1", 1, s);
}
NR > 1 {
    printf "\n"
}
{
    printf trim($0)
}