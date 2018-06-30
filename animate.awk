#!/usr/bin/gawk -f

@include "lib/glib.awk"

BEGIN {
  scrwidth = 54
  scrheight = 60

  # bail out if terminal isn't big enough
  chksize(scrwidth, scrheight)
  init(myscr, scrwidth,scrheight)

  # clear screen, turn off cursor
  clrscr()
  cursor("off")
  start = then = now = timex()

  # load spritemap
  loadxpm2(scott, "gfx/scottpilgrim_spritemap.xpm2")

  # set animation parameters
  scott["animation"]["last"] = 0
  scott["animation"]["interval"] = 0.1
  scott["animation"]["type"] = "row"
  scott["animation"]["loop"] = "loop"
  scott["animation"]["width"] = 54
  scott["animation"]["height"] = 60
  scott["animation"]["x"] = 0
  scott["animation"]["y"] = 0
  scott["animation"]["dx"] = 1
  scott["animation"]["dy"] = 0

  # set numer of frames to draw and target FPS
  maxframes = 1000
  targetfps = 10

  # main loop
  for (framenr=0; framenr<maxframes; framenr++) {
    printf("\033[H")
    clear(myscr, color["brightblue"])

    # do animation of scott and copy sprite to myscr buffer
    animate(scott)
    copy2(scott, myscr, scott["animation"]["x"],scott["animation"]["y"], scott["animation"]["width"],scott["animation"]["height"], 0,0)

    # draw myscr buffer to terminal
    draw(myscr, 0,0)

    # add status bar with FPS
    frame++
    now = timex()
    if (now > (then+0.5) || cls) {
      printf("\033[Hframe: %4d/%4d size: %dx%d fps: %5.2f avg: %5.2f (target: %.2f)\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], frame/(now-then), framenr/(now-start), targetfps)
      frame = 0
      then = now
    }

   # delay to reach target FPS
   fps(targetfps)
  }

  # draw final status bar and turn on cursor again
  printf("\033[Hframe: %4d/%4d size: %dx%d fps: %5.2f avg: %5.2f\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], frame/(now-then), framenr/(now-start))
  cursor("on")
}

