
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/types.h>
#include <unistd.h>

#include "gawkapi.h"

// free()
#include <malloc.h>

int plugin_is_GPL_compatible;

static const gawk_api_t *api;
static awk_ext_id_t ext_id;
static const char *ext_version = "0.1";
static awk_bool_t (*init_func)(void) = NULL;

static const char *shell = "/bin/bash";

static void
exec_atexit_handler(void *data, int exit_status) {
    int ret;
    ret = execl(shell, shell, "-c", (char *)data, (char *)NULL);
    if(ret < 0)
	update_ERRNO_int(errno);
    free(data);
};

static awk_value_t *
do_exec(int nargs, awk_value_t *result)
{
    if (do_lint && nargs != 1 && nargs != 2)
	lintwarn(ext_id, "exec: called with incorrect number of arguments");

    awk_value_t cmd;
    get_argument(0, AWK_STRING, &cmd);
    if(nargs == 2) {
	awk_value_t run_end;
	get_argument(1, AWK_NUMBER, &run_end);

	if(run_end.num_value) {
	    // for this trick to work this extension needs to be loaded *first*,
	    // otherwise other atexit handlers may not get executed
	    awk_atexit(exec_atexit_handler, strdup(cmd.str_value.str));
// these don't not work, need to call exit from script:
//	    exit(0);
//	    gawk_exit(0);
	    return make_number(0, result);
	}
    }
    
    int ret;
    fflush(NULL);
    ret = execl(shell, shell, "-c", cmd.str_value.str, (char *)NULL);
    if(ret < 0) // error
	update_ERRNO_int(errno);
    return make_number(ret, result);
};

static awk_ext_func_t func_table[] = {
    { "exec", do_exec, 2 },
};

// this is implemented as macro, and the second argument is converted to a string!!
dl_load_func(func_table, exec, "")
