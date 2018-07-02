#!/usr/bin/gawk -f
## Sample ASCII/ANSI picture viewer using awk-glib
# requirements are an installed version of ImageMagick (convert) and sed

@include "lib/glib.awk"

BEGIN {
  # get terminal width and height
  width = terminal["width"]
  height = (terminal["height"]-1)*2

  init(myscr, width, height)

  xpmfile = file ".xpm"
  xpm3toxpm2 = "sed 's/^static char.*/! XPM2/;/^\\/\\*/d;s/^\"//;s/\",\\?//;/^};/d'"

  # process all files/arguments
  for (i=1; i<ARGC; i++) {
    file = ARGV[i]

    # convert, load and delete converted image
    cmd = sprintf("convert -geometry %dx%d \"%s\" xpm:- | %s >\"%s\"", width, height, file, xpm3toxpm2, xpmfile)
    system(cmd)
    loadxpm2(mypic, xpmfile)
    cmd = sprintf("rm \"%s\"", xpmfile)
    system(cmd)
 
    # clear buffer, copy image and draw buffer 
    clear(myscr)
    copy(myscr, mypic, centerx(mypic,myscr), centery(mypic,myscr))
    draw(myscr)

    printf("press [ENTER] (%s)", file)
    getline junk < "/dev/stdin" 
  }
}
