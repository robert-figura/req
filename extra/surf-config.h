
#define DOWNLOAD(uri, referer) { \
        .v = (const char *[]){ "req", "-p", "download", "-f", "surf", \
             "-a", "useragent", useragent, \
	     "-a", "referer", referer, \
	     "-a", "cookiefile", cookiefile, \
	     "-e", uri, NULL \
        } \
}

#define PLUMB(uri) { .v = (const char *[]){ "dispatch", "-f", "surf", "-e", uri, NULL } }
#define VIDEOPLAY(uri) PLUMB(uri)

void
clickplumb(Client *c, const Arg *a, WebKitHitTestResult *h)
{
	Arg arg;

	arg = PLUMB(webkit_hit_test_result_get_link_uri(h));
	spawn(c, &arg);
}

/* bind middle click to send link to plumber: */
static Button buttons[] = {
	/* ... */
	{ OnLink,       0,              2,      clickplumb,        { 0 },          1 },
	/* ... */
};
