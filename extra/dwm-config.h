
/* define DISPATCH macro to call req */
#define DISPATCH(ARG) (const char*[]){ "req", "-p", "dispatch", "-f", "dwm", "-e", ARG, NULL }
/* if you have extra/dispatch in your $PATH you should call that instead: */
/* #define DISPATCH(ARG) (const char*[]){ "dispatch", "-f", "dwm", "-e", ARG, NULL } */

static Button buttons[] = {
	/* click                event mask      button          function        argument */

        /* ... */
	{ ClkWinTitle,          0,              Button1,        spawn,          {.v = DISPATCH("event:title-button-1")} },
	{ ClkWinTitle,          0,              Button2,        spawn,          {.v = DISPATCH("event:title-button-2")} },
/*	{ ClkWinTitle,          0,              Button3,        zoom,           {0} }, */
	{ ClkStatusText,        0,              Button1,        spawn,          {.v = DISPATCH("event:status-button-1")} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = DISPATCH("event:status-button-2")} },
	{ ClkStatusText,        0,              Button3,        spawn,          {.v = DISPATCH("event:status-button-3")} },
	/* ... */
}
