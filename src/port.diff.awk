
{
    run("tkdiff " Q($1) " "Q($2)) # http://sourceforge.net/projects/tkdiff/
#    run("xfdiff " Q($1) " "Q($2)) # http://xffm.sourceforge.net/
#    run("diffuse " Q($1) " "Q($2)) # http://diffuse.sourceforge.net/
#    run("meld " Q($1) " "Q($2)) # http://meld.sourceforge.net/
    run(pager("wdiff " Q($1) " " Q($2))) # http://www.gnu.org/software/wdiff/
    run(pager("diff -Naur " Q($1) " " Q($2)))
}

{
    $0 = $2
}

# so when using this as diff client in dvcs gui we get more options:
@include "port.open.awk"
