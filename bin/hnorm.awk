#!/bin/awk -f

BEGIN {
    if(!match(url, /^https?:/))
	url = "http://" url
    gsub(/\?.*$/, "", url)
    gsub(/\/?$/, "/", url)
    match(url, /^(https?):\/\/([^\/]*)\//, m)
    host = m[1] "://" m[2]
}
/^\// {
    $0 = host $0
}
! /^https?:/ {
    $0 = url $0
}
{
    gsub(/\/[^\/]*\/\.\./, "")
    sub(/^http:\/\/:\/*/, "http://")
    print
}
