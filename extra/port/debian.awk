
get("phrase") {
    label("deb package search"); menu(pager("apt-cache search -n " Q(get("phrase"))))
}

get("file_name") {
    label("deb locate file (dpkg-query)"); menu(pager("dpkg-query -S " Q(get("file_name"))))
}

s = get("identifier") {
    let("auto", ctx("xprop_WM_NAME") ~ /^(deb package search|apt-cache search|deb show|apt-cache show)/)
    label("deb show (apt-cache)"); menu(pager("apt-cache show " Q(s)))
    
    label("deb homepage (apt-cache)"); menu("apt-cache show " Q(s) " | awk '/^Homepage: /{print$2}' | " req("browser", "-stdin"))
    label("deb depends (apt-cache)"); menu(pager("apt-cache depends " Q(s)))
    label("deb rdepends (apt-cache)"); menu(pager("apt-cache rdepends " Q(s)))
    label("deb list files (dpkg-query))"); menu(pager("dpkg-query -L " Q(s)))
}
