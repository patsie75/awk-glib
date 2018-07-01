#!/usr/bin/gawk -f

@include "lib/glib.awk"

BEGIN {
  srand()
  start = then = now = timex()
  maxframes = 100
  targetfps = 10

  plumber = 0
  lizard = 1
  princess = 2

  # set transparent color
  glib["transparent"] = color["cyan"]

  # initialize myscr buffer with size
  chksize(160, 100)
  init(myscr, 160, 100)

  myspr[plumber]["x"] = 0
  myspr[lizard]["x"] = 0
  myspr[princess]["x"] = 0

  # load sprites
  load(myspr[plumber],  "gfx/plumber.gfx")
  load(myspr[lizard],   "gfx/lizard.gfx")
  load(myspr[princess], "gfx/princess.gfx")
  load(floorspr,        "gfx/floor.gfx")
  load(cloudspr,        "gfx/cloud.gfx")

  # set sprite attributes (position, speed, flipped)
  for (i=plumber; i<=princess; i++) {
    switch (int(rand() * 4)) {
      case 0: hflip(myspr[i], myspr[i]); break
      case 1: vflip(myspr[i], myspr[i]); break
    }

    myspr[i]["x"]  = int(rand() * (myscr["width"]  - myspr[i]["width"]) )
    myspr[i]["y"]  = int(rand() * (myscr["height"] - floorspr["height"] - myspr[i]["height"]) )
    myspr[i]["dx"] = int(rand() * 2) ? -1 : 1
    myspr[i]["dy"] = int(rand() * 2) ? -1 : 1
  }

  ## create four (possible horizontally flipped) clouds
  for (i=0; i<4; i++) {
    for (j in cloudspr) cloud[i][j] = cloudspr[j]
    if (int(rand() * 4) % 4 == 0) vflip(cloud[i], cloud[i])
    cloud[i]["x"] = rand() * (myscr["width"] + cloud[i]["width"]*2) - cloud[i]["width"]
    cloud[i]["y"] = rand() * (myscr["height"]/4)
    cloud[i]["dx"] = rand() * 0.4 + 0.2
  }

  cursor("off")
  while (framenr++ < maxframes) {
    # clear mysc buffer to bright blue
    clear(myscr, color["brightblue"])

    # draw floor tiles
    for (i=0; i<myscr["width"]/floorspr["width"]; i++)
      copy(myscr, floorspr, i*floorspr["width"], myscr["height"]-floorspr["height"])
  
    # move and draw the clouds 
    for (i=0; i<4; i++) {
      # move cloud
      cloud[i]["x"] -= cloud[i]["dx"]

      # left off screen
      if (cloud[i]["x"] < (cloud[i]["width"]*-1)) {
        cloud[i]["x"] = myscr["width"]
        cloud[i]["y"] = rand() * (myscr["height"]/4)
        cloud[i]["dx"] = rand() * 0.4 + 0.2
      }
      # right off screen
      if (cloud[i]["x"] > myscr["width"]) {
        cloud[i]["x"] = (cloud[i]["width"]*-1)
        cloud[i]["y"] = rand() * (myscr["height"]/4)
        cloud[i]["dx"] = rand() * 0.4 + 0.2
      }
      # draw cloud to myscr buffer
      copy(myscr, cloud[i])
    }

    # move and draw sprites
    for (spr=plumber; spr<=princess; spr++) {
      myspr[spr]["x"] += myspr[spr]["dx"]
      myspr[spr]["y"] += myspr[spr]["dy"]
      if ( (myspr[spr]["x"] < -10) || (myspr[spr]["x"] >= (myscr["width"]  - myspr[spr]["width"]) + 10) )  myspr[spr]["dx"] *= -1
      if ( (myspr[spr]["y"] <= -10) || (myspr[spr]["y"] >= (myscr["height"] - floorspr["height"] - myspr[spr]["height"])) ) myspr[spr]["dy"] *= -1
  
      copy(myscr, myspr[spr])
    }

    # display myscr buffer on terminal
    draw(myscr, myscr["x"],myscr["y"])

    # add status bar
    frame++
    now = timex()
    if (now > (then+0.5)) {
      printf("\033[Hframe: %4d/%4d size: %dx%d fps: %5.2f avg: %5.2f\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], frame/(now-then), framenr/(now-start))
      frame = 0
      then = now
    }

    # sleep a bit
    fps(targetfps)
  }

  # save screenshot
  save(myscr, "screen.gfx")

  cursor("on")
  printf("\n")
}
