
= exec.so gawk extension =

exec.so gawk extension for calling the execl() system function from gawk.


= QUICK START =

You'll need a gawkapi.h matching your gawk installation.

1. Copy config.mk.sample to config.mk and edit to tell make where to find gawkapi.h

2. Call make to build the extension

This should also test it so you'll know if it works.

3. To load the extension, call gawk with the -l flag_

gawk -l /path/to/extensions/exec.so
AWKLIBPATH=/path/to/extensions gawk -l exec.so

4. There are two methods to call exec() from within gawk, this one
_will not_ run the END section of your awk script:

{
  exec("shell script")
}

But if you give exec a 1 as second parameter, it will run the END
section. But you have to manually trigger gawk's shutdown. I'm sorry
for the hack:

{
  exec("shell script", 1)
  exit 123
}

The second method is better as it fits better into gawk's philosophy
and it will lead to simpler scripts.


== Why two implementations? ==

The simplest way is to just call the execl() system function from this
extension. That can be made work, bit it will not evaluate the END
section of your awk scripts.

I think that is not a desireable behaviour, so there's an alternative
implementation that will run the system call in the at_exit handler
while gawk is shutting down. I haven't found a way to properly
shutdown gawk from within the extions so you need to call exit()
yourself right after calling exec(cmd, 1)!

There may be another caveat to the second method: Since the extension
implicitly terminates the gawk process in its at_exit handler, any
cleanup gawk might need to do after our at_exit handler will be left
undone. This doesn't seem to be a problem for gawk itself, but other
extension's exit handlers may be missed. Just make sure you load other
extensions before loading exit.so!
