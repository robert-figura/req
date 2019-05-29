
# log labels, commands, or other properties
func log_add(file, prop) {
    log_map[file] = log_map[file] " " prop
}
func log_flush(    file, prop, p, s) {
    for(file in log_map) {
	split(log_map[file], p)
	for(prop in p)
	    if(s = get(prop))
	        print s >> file
	close(file)
    }
}
END {
    log_flush()
}
