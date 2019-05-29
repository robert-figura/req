
func decrypt_a(uri,    s, m) {
    if(!decrypt_cache_loaded++)
	file_get_map(REQ_DIR "/decrypt.cache", decrypt_cache, "", " = ")
    if(uri in decrypt_cache)
	return decrypt_cache[uri]
    s = backtick("curl -s " Q(uri))
    # todo: generalize and implement decrypting header based redirect
    if(!match(s, /document has moved <A HREF="([^"]*)">here<\/A>/, m))
	return ""
    decrypt_cache[uri] = m[1]
    file_put_map(REQ_DIR "/decrypt.cache", decrypt_cache, " = ")
    return m[1]
}

get("uri_domain") == "google.com" && get("uri_path") == "/url" && get("http_arg_q") {
    set("decrypted", get("http_arg_q"))
}
get("uri_domain") == "google.com" && get("uri_path") == "/imgres" {
    set("decrypted", get("http_arg_imgrefurl"))
    label("surf (image)"); menu(browser(get("http_arg_imgurl")))
}
get("uri_domain") == "facebook.com" && get("http_arg_redirect_uri") {
    set("decrypted", get("http_arg_redirect_uri"))
}
get("uri_domain") == "youtube.com" && get("uri_path") ~ /^\/(attribution_link)/ {
    set("decrypted", "https://www.youtube.com" get("http_arg_u"))
}

get("uri_domain") == "goo.gl" && get("uri_path") {
    set("decrypted", decrypt_a(get("uri")))
}

# replace http property, offer to open encrypted
get("decrypted") && !(0+get("no_decrypt")) {
    set("history_override", get("decrypted"))
    split_uri(get("decrypted"), m)
    set("http", join_uri(m))
    setArray("http", m)
    label("encrypted"); menu(req("", "-a no_decrypt 1", get("uri")))
}
