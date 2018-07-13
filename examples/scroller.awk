BEGIN {
  scrwidth = 160
  scrheight = 100

  targetfps = 300

  chksize(scrwidth, scrheight)
  start = then = now = timex()

  if (ARGC > 1) scrolltext = "          " toupper(ARGV[1]) "          "
  else scrolltext = "          >>>>> OLD SKOOL SCROLLERS ARE THE BEST...    ESPECIALLY WHEN THEY ARE IN YOUR FAVOURITE XENON2 STYLE FONT   COOL HUH <<<<<    SEE YOU NEXT TIME          "

  # load font and set characterset
  loadxpm2(font, "gfx/xenon2.xpm2")
  font["font","charset"] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.:><0123456789+"
  font["font","width"] = 16
  font["font","height"] = 24

  ## init screen and scroller buffers
  init(myscr, scrwidth, scrheight)
  init(scroller, length(scrolltext)*font["font","width"], font["font","height"])
  write(scroller, font, 0,0, scrolltext)

  clrscr()
  cursor("off")

  # do for length of scrolltext
  for (i=0; i<(scroller["width"]-myscr["width"]); i++) {
    framenr++
    clear(myscr)

    # create sinewave from scroller
    for (x=0; x<myscr["width"]; x++) {
      # copy(dst, src, dstx, dsty, srcx, srcy, srcw, srch)
      copy(myscr, scroller, x,int(glib["sin",((x*2)+i)%360]/16)+40, (i+x),0, 1,scroller["height"])
    }

    draw(myscr)

    # add status bar with FPS
    frame++
    now = timex()
    if (now > (then+0.5)) {
      printf("\033[Hframe: %4d/%4d size: %dx%d fps: %5.2f avg: %5.2f (target: %.2f)\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], frame/(now-then), framenr/(now-start), targetfps)
      frame = 0
      then = now
    }

   # delay to reach target FPS
   fps(targetfps)
  }

  # draw final status bar and turn on cursor again
  printf("\033[Hframe: %4d/%4d size: %dx%d fps: %5.2f avg: %5.2f (target: %.2f)\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], frame/(now+0.01-then), framenr/(now-start), targetfps)

  cursor("on")
}
