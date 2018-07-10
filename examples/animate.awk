BEGIN {
  # necessary screen width and height
  scrwidth = 120
  scrheight = 100

  # set numer of frames to draw and target FPS
  maxframes = 400
  targetfps = 20

  # bail out if terminal isn't big enough
  chksize(scrwidth, scrheight)
  init(myscr, scrwidth,scrheight)

  # clear screen, turn off cursor
  clrscr()
  cursor("off")
  start = then = now = timex()

  # load spritemap and skyline
  loadxpm2(scott, "gfx/scottpilgrim_spritemap.xpm2")
  loadxpm2(skyline, "gfx/skyline2.xpm2")

  # set animation parameters
  scott["animation","last"] = 0
  scott["animation","interval"] = 0.1
  scott["animation","type"] = "row"
  scott["animation","loop"] = "loop"
  scott["animation","width"] = 54
  scott["animation","height"] = 60
  scott["animation","x"] = 0
  scott["animation","y"] = 0
  scott["animation","dx"] = 1
  scott["animation","dy"] = 0

  # create background image from double skyline
  init(background, skyline["width"]*2, skyline["height"])
  copy(background, skyline)
  copy(background, skyline, skyline["width"]-1)

  # set movement parameters for background
  background["x"] = 0
  background["y"] = 0
  background["dx"] = -3
  background["dy"] = 0


  # main loop
  for (framenr=0; framenr<maxframes; framenr++) {
    #printf("\033[H")

    # move background and reset when limit reached
    background["x"] += background["dx"]
    if (background["x"] <= (skyline["width"]*-1))
      background["x"] += skyline["width"]
    copy(myscr, background)

    # do animation of scott and copy sprite to myscr buffer
    animate(scott)
    copy(myscr, scott, centerx(scott,myscr), myscr["height"]-scott["animation","height"])

    # draw myscr buffer to terminal
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

