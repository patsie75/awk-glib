#!/usr/bin/gawk -f

@include "lib/glib.awk"

BEGIN {
  srand()

  # initialize myscr buffer with size
  init(myscr, 100, 80)

  # load two sprites and set position and speed attributes
  load(myspr1, "gfx/plumber.gfx")
  myspr1["x"] = int(rand() * (myscr["width"]  - myspr1["width"]) )
  myspr1["y"] = int(rand() * (myscr["height"] - myspr1["height"]) )
  myspr1["dx"] = myspr1["dy"] = 1

  load(myspr2, "gfx/lizard.gfx")
  myspr2["x"] = int(rand() * (myscr["width"]  - myspr2["width"]) )
  myspr2["y"] = int(rand() * (myscr["height"] - myspr2["height"]) )
  myspr2["dx"] = myspr2["dy"] = -1

  cursor("off")
  clearscr()

#  while ("awk" != "difficult") {
  while (framenr++ < 60000) {
    # determine location of myscr buffer
    switch ((framenr/100) % 5) {
      case 0: clearscr(); myscr["x"] = 0; myscr["y"] = 0; break;
      case 1: clearscr(); myscr["x"] = 1; myscr["y"] = 3; break;
      case 2: clearscr(); myscr["x"] = -1; myscr["y"] = -1; break;
      case 3: clearscr(); myscr["x"] = -1; myscr["y"] = 3; break;
      case 4: clearscr(); myscr["x"] = 1; myscr["y"] = -1; break;
    }

    printf("\033[H")
#    printf("term: %dx%d\n", terminal["width"], terminal["height"]*2)
#    printf("scrn: %dx%d\n", myscr["width"], myscr["height"])
    printf("spr1: %dx%d (%3dx%3d) [%2d/%2d]\n", myspr1["width"], myspr1["height"], myspr1["x"], myspr1["y"], myspr1["dx"], myspr1["dy"])
    printf("spr2: %dx%d (%3dx%3d) [%2d/%2d]\n", myspr2["width"], myspr2["height"], myspr2["x"], myspr2["y"], myspr2["dx"], myspr2["dy"])
    clear(myscr, color["white"])

    # move myspr1 and copy to myscr buffer
    myspr1["x"] += myspr1["dx"]
    myspr1["y"] += myspr1["dy"]
    if ( (myspr1["x"] < -10) || (myspr1["x"] >= (myscr["width"]  - myspr1["width"]) + 10) )  myspr1["dx"] *= -1
    if ( (myspr1["y"] < -10) || (myspr1["y"] >= (myscr["height"] - myspr1["height"]) + 10) ) myspr1["dy"] *= -1

    copy(myscr, myspr1, myspr1["x"], myspr1["y"], color["cyan"])

    # move myspr2 and copy to myscr buffer
    myspr2["x"] += myspr2["dx"]
    myspr2["y"] += myspr2["dy"]
    if ( (myspr2["x"] < -10) || (myspr2["x"] >= (myscr["width"]  - myspr2["width"]) + 10) )  myspr2["dx"] *= -1
    if ( (myspr2["y"] < -10) || (myspr2["y"] >= (myscr["height"] - myspr2["height"]) + 10) ) myspr2["dy"] *= -1

    copy(myscr, myspr2, myspr2["x"], myspr2["y"], color["cyan"])

    # display myscr buffer centered on terminal and sleep a little bit
    draw(myscr, myscr["x"],myscr["y"])
    system("sleep 0.01")
  }

  save(myscr, "screen.gfx")

  cursor("on")
  printf("\n")
}

