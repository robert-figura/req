#!/bin/bash

# example: fetch fresh images from flickr:
# curlink.sh 'http://www.flickr.com/photos/' | grep //farm | grep -v /buddyicons/ | sed 's/_[stm]\.jpg/_z.jpg/1' | while read u ; do echo "$u" ; curl -s "$u" > x.jpg ; xli x.jpg ; done

# otherwise google won't work:
USER_AGENT="Mozilla/5.0 (X11; U; Linux; en-us) AppleWebKit/531.2+ (KHTML, like Gecko, surf-0.4.1) Safari/531.2+"

function hnorm {
  gawk -f "$REQ_DIR/bin/hnorm.awk" "$@"
}
function href {
  gawk -f "$REQ_DIR/bin/href.awk" "$@"
}
function curlink {
  curl -A "$USER_AGENT" -s "$2" |
  href -v allow="$1" |
  hnorm -v url="$2"
}
function curlink_read {
  while read url ; do
    curlink "$1" "$url"
  done
}

allow="a"
while test -n "$1" ; do
  case "$1" in
    -a) # set allowed tags
      allow="$2"
      shift
      ;;
    -s) # urls from stdin
      curlink_read "$allow"
      ;;
    -f) # urls from file
      curlink_read "$allow" < "$2"
      shift
      ;;
    *)  # url from arguments
      curlink "$allow" "$1"
      ;;
  esac
  shift
done
