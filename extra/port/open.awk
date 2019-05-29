
@include "libsplit.awk"
@include "classify.awk"

@include "libwrapper.awk"

@include "file.awk"
@include "uri.awk"
@include "search.awk"

@include "proc.awk"

@include "default.awk"

# show full classification matches in prompt
{
    set("menu_prompt", keys(is_a) ": " get("menu_prompt"))
    delete is_a["menu_prompt"]
}
