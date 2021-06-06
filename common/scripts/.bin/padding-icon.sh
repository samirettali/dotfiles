#!/usr/bin/env bash

create_xpm_icon () {
  timestamp=$(date)
  pixels=$(for i in `seq $1`; do echo -n "."; done)

  cat << EOF > "$2"
/* XPM *
static char * trayer_pad_xpm[] = {
/* This XPM icon is used for padding in xmobar to */
/* leave room for trayer-srg. It is dynamically   */
/* updated by by trayer-pad-icon.sh which is run  */
/* by xmobar.                                     */
/* Created: ${timestamp} */
/* <w/cols>  <h/rows>  <colors>  <chars per pixel> */
"$1 1 1 1",
/* Colors (none: transparent) */
". c none",
/* Pixels */
"$pixels"
};
EOF
}

pname=${1:-panel}

width=$(xprop -name $pname | grep 'program specified minimum size' | cut -d ' ' -f 5)

iconfile="/tmp/$pname-padding-${width:-0}px.xpm"

if [ ! -f $iconfile ]; then
    create_xpm_icon $width $iconfile
fi

echo "<icon=${iconfile}/>"
