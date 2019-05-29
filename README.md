
# req – gawk and dmenu powered plumberlike

[req.png]

...plumber? _I seem to remember thinking that it was sort of awk inspired_
(*Aharon Robbins* in comp.lang.awk)

*req* is a text snippet router similar to plan9's plumber[¹], but you get
gawk scripting for rules, and both, record and context matching.

It is a desktop accelerator: a frontend for searching, launching, and
automating.


# INTENDED AUDIENCE

You are comfortable writing short one-line shell scripts and know a
little about regular expressions. You might well get along, give it a
try!

If you furthermore enjoy writing awk scripts, and know a bit about
unix' intricacies then req is for you!


# CONCEPT

*req* is a text snippet router: given a string, say from your X11 cut
buffer, it will classify and extract information contents, and merge
that with context information. You write rule files ("ports") in awk
to match against this data and to generate a menu of available shell
commands.

Each of the stages - gathering context, classifying, and constructing
a menu - is written in gawk and fully under your control. The basic
framework presents the data as layered namespaces, and offers
libraries and wrappers to construct shell commands in concise rules.

This project disputes the raison d'etre of xdg-open, dbus, .desktop
files, file associations, and many other 'important' desktop features.
Yes, something should sit there right at the center, and our aim is to
regain full control over all our inter-application workflows, and put
the power back into the hands of the user: You!


# DEPENDENCIES

- gawk >= 4.1:
  http://www.gnu.org/software/gawk/gawk.html


# GETTING STARTED

0. Clone this repository to a directory named '.req' in your home
directory.

1. Copy req.conf.sample to req.conf, and edit to your delight.

2. Create a directory named ~/.req/port/ for your stuff.

3. The default port is port/open.awk. Create that file and write your
first rule:

```
get("file_mimetype") == "text/plain" {
    auto(1); menu("less " Q(get("file_name")))
}
```

4. test it:

```
$ ls / > test.txt
$ req -p open -t test.txt
$ req -p open -t -i test.txt
```

5. Put the frontend somewhere into your path and start hacking!

*Suggestion:* This rule can show you the available properties given
any input string:

```
{
    label("DUMP"); call("dump")
}
```

Or use the '-D' info mode instead.

*Suggestion:* Invent your own ad-hoc protocols and microformats!

*Suggestion:* If you have a comfy working ruleset do `git commit` to
back it up! Just add your files to req's checkout, and find yourself
ready to share your code! Pull requests welcome!

*Suggestion:* Build and configure the exec.so gawk plugin to get rid
of excess intermediate processes!

https://github.com/robert-figura/req/blob/master/src/README.md

*Suggestion:* Make sure your TEMP environment variable points into a
tmpfs/ramdisk mount. Req temporarily creates short-lived files for
data, context, and possibly other stuff, and you may want to avoid
writing to disk too frequently.

*Suggestion:* Grep the source for menu labels, command names, or
namespace elements!

*Suggestion:* Read the examples! Maybe start here:

https://github.com/robert-figura/req/blob/master/extra/port/open.awk

There's so much more!

https://github.com/robert-figura/req/blob/master/extra/README.md


# SYNOPSIS

A commandline frontend to bind it all together, and bind it in a
user-friendly api.

```
req-0.4.4, (c) 2012-2019 Robert Figura, see LICENSE for details

req [-OPTIONS...] [--] DATA
req [-OPTIONS...] -file DATA_FILE
req [-OPTIONS...] -stdin

ARGUMENTS
  -p <name>          'port' what to do (default: open)
  -f <name>          'from' triggering application (default: shell)
  -a <key> <value>   assign argument
  -A <file>          import argument file
  -R <file>          import and remove argument file

INPUT
  -- ...             suppress option parsing for remaining arguments
  -e ...             rest of commandline is a single data record
  -|-stdin           read from stdin and exit
  -d|-file <file>    read data from file

FILTERS
  -1|-single         exit after processing the first record
  -%|-percent        substitute e.g. %xwin in data
  -u|-uniq           filter duplicate input lines
  -#|-comment        remove comments
  -_|-empty          filter empty lines

MENU
  -i|-menu           always display interactive menu
  -s|-select <num>   select from menu, -select <number>
  -q|-quiet          inhibit menu prompt (for unpatched dmenu)

INFO
  -t                 print command instead of running it
  -X                 dump context and exit
  -C                 dump classification
  -D                 dump internal state
  -x|-ctx <prop>     print context property and exit
  -c|-class <prop>   print property for each record
  -l|-list <prop>    print property per available choices
  -T|-test <prop>    print property after choice
  -V|-version        print version info
  -h|-help           print version and usage info
```


# SHOW CASE

The rules for the following examples can be found in the files under
extra/port/

```
# note: -t shows the command instead of executing it, 

# It's a mimetype based file launcher:
$ mv lorem-ipsum.pdf z.doc
$ req -t z.doc
mupdf -cont -z width '/home/rfigura/z.doc'
# Note that it isn't fooled by the "wrong" file name extension.

# It's an url launcher, too:
$ req -t http://localhost/
surf -n 'http://localhost/'

# For some urls scripting is turned off:
$ req -t http://w3c.org/
surf -p -s 'http://w3c.org/'

# Some urls get downloaded:
$ req -t http://localhost/t.pdf
curl -O -L 'http://localhost/t.pdf'
# Note that the actual command includes starting an xterm and
# is a bit longer. But the above line is part of it, check it out!
```


# LINKS

- Homepage
  https://github.com/robert-figura/req

- [¹] "Plumbing and Other Utilities", Rob Pike
  http://doc.cat-v.org/plan_9/4th_edition/papers/plumb


## suggested software

Most of these dependencies can easily be changed in the source code, or fail reasonably.

- file (file type recognition)
  http://www.darwinsys.com/file/
- dmenu (fast x11 menu)
  http://suckless.org/dmenu
- xclip (x11 clipboard support)
  http://xclip.sourceforge.net/
- xprop (x11 window context detection)
  http://xorg.freedesktop.org/wiki
- xbindkeys (for hotkey daemon)
  http://hocwp.free.fr/xbindkeys/xbindkeys.html
- xterm (auto-set xterm background examples)
  http://invisible-island.net/xterm
- gawkapi.h headers, gnu make, and some c compiler (for exec.so support)
  http://www.gnu.org/software/gawk/gawk.html
- less (the default pager)
  http://www.greenwoodsoftware.com/less
- surf (minimalist browser)
  http://surf.suckless.org/
- dwm (fast tiling windowmanager)
  http://suckless.org/dwm
- git (to back up your rules and share our code)
  http://git-scm.com/
- wpa_supplicant's wpa_cli (for wifi context detection)
  http://w1.di/wpa_supplicant/

## related projects

- *plan9port*'s plumber: an implementation very close to Rob Pike's plumber
  http://swtch.com/plan9port
- *xdg-utils*: freedesktop.org's reference implementation
  https://wiki.freedesktop.org/www/Software/xdg-utils/
- *mimeinfo*: mimeinfo based replacement for the file utility, written in perl
  https://metacpan.org/release/File-MimeInfo
- *mimeo*: unifies xdg-open and xdg-mime, written in python
  http://xyne.archlinux.ca/projects/mimeo
- *linopen*: "Intelligent and suckless replacement for xdg-open"
  http://cloudef.eu
- *mimi-git*: "mimi is an improved verision of xdg-open.", written in bash
  http://github.com/taylorchu/mimi
- *sx-open*: "a saner alternative to xdg-open", written in bash
  https://git.fleshless.org/sx-open
- *busking-git*: "A simple, regex-based xdg-open replacement", written in perl
  https://github.com/supplantr/busking
- *whippet*: "A launcher and xdg-open replacement for control freaks, utilizing dmenu.", written in bash
  http://appstogo.mcfadzean.org.uk/linux.html#whippet
