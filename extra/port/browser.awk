
# Decide on browser settings and cookie file based on url (and ctx,
# and class).

# This wrapper is basically a classification scheme with a single
# command constructed based on the accumulated settings. The browser()
# function is a frontend for this port, but you can also just @include
# this file from your port/open.awk.

# I hope you can see that it makes sense to have these classifications
# in a separate file. It turns out it does not make too much sense to
# have this as a pure classification file, since it should exactly
# control starting a single browser instance.

@include "libsplit.awk"
@include "classify.awk"

@include "libwrapper.awk"

{
    # defaults
    def("cookie_file", "/dev/null")
}

# a shortcut
get("http_domain") == "google.com" && get("http_args_tbm") == "isch" {
    set("google_image_search", 1)
}

# allow images
is_in(get("http_domain"), "\
wikipedia.org \
facebook.com \
youtube.com \
") ||
is_in(get("http_host"), "\
plus.google.com \
") ||
get("google_image_search") {
    set("allow_image", 1)
}

# allow script
is_in(get("http_domain"), "\
youtube.com \
") ||
is_in(get("http_host"), "\
plus.google.com \
") ||
get("google_image_search") {
    set("allow_script", 1)
}

# per domain cookies
is_in(get("http_domain"), "\
facebook.com \
") {
    set("cookie_file", get("http_domain"))
}
# per host cookies
is_in(get("http_host"), "\
encrypted.google.com \
") {
    set("cookie_file", get("http_host"))
}

# google club, add your allowed g+ apps here
is_in(get("http_host"), "\
plus.google.com \
") {
    set("cookie_file", "accounts.google.com")
}

# different cookies depending on the login
match(get("http"), /https:\/\/github.com\/([^/]*)\//, m) {
    set("cookie_file", "github.com-" m[1])
}

# incorporate cookie_dir into cookie_file # todo: is this a hack?
get("cookie_file") ~ /^[^/]/ { # e.g. /dev/null
    set("cookie_file", get("cookie_dir") "/cookies." get("cookie_file") ".txt")
}

################################################################

# run browser using flags defined above
get("http") {
    auto(is_a["http"]); menu(surf(get("http")))
}
