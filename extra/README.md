
= setup scripts for supported applications =

- *setup-bash*: set environment variables supported by many applications
- *setup-rox*: add req as mimetype handler for everything
- *setup-mimeapps*: add catch-all rule to call req via original xdg-open
- *setup-mailcap*: example ~/.mailcap as supported by mutt, sylpheed, ...

- *dwm-config.h*: add this to your dwm's config.h
- *surf-config.h*: add this to your surf's config.h

= port examples =

Writing good port files is as much a question about style as it is about
experience. These files are intended to boost your imagination and help
doing things in the most effective way right from the start. 

= extra scripts =

Additional scripts that benefit from req's libraries. Some of them may
seem like it might be a good idea to have them as part of the main
engine, but I have tried, and it's not. So here they are as negative
examples, and as starting point in case you'd still like to do things
in gawk:

- *dl*: download helper script
- *youtube-playlist*: extract and display youtube playlist as text
- *dispatch*: frontend for `req -p dispatch`, single configuration point
  - *xdg-open*: drop-in replacement for freedesktop's xdg-open
- *wrappers*: 
  - *xterm.awk*: framework to parse commandline arguments, xterm colorization 
  - *completion*: boilerplate for handling bash completion requests, example

= disable at-spi2 =

at-spi2 is evil, as it sends every keypress and mouseclick over dbus
to any interested subscriber. See for yourself:

$ dbus-monitor --address `xprop -root | grep '^AT_SPI_BUS' | sed -ne 's/.*= "//;s/"$//;p'`

Unless you depend on its accessibility features, uninstall
at-spi2-core now!

= disable dbus =

You first need to disable your desktop session management. I wouldn't
know how to do that because I'm using xdm for display management and
pure dwm as session manager.

On debian you can change some session defaults independent of the
session manager in the file /etc/X11/Xsession.options:

no-use-session-dbus
# can disable ssh-agent, too, if xou don't want it:
# no-use-ssh-agent

But your applications might still attempt to autolaunch dbus. Adding
the following line to your relevant .xsessionrc, .xinitrc, or .profile
should work:

export DBUS_SESSION_BUS_ADDRESS=invalid:

