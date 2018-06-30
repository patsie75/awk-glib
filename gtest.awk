#!/usr/bin/gawk -f

@include "lib/glib.awk"

BEGIN {
  srand()

  start = then = now = timex()
  maxframes = 100

  plumber = 0
  lizard = 1
  princess = 2

  # initialize myscr buffer with size
  init(myscr, 160, 100)

  myspr[plumber]["x"] = 0
  myspr[lizard]["x"] = 0
  myspr[princess]["x"] = 0
  bgimg["x"] = 0

  # load sprites
  load(floor, "gfx/floor.gfx")
  floor["transparent"] = color["cyan"]
  load(cloudgfx, "gfx/cloud.gfx")
  cloudgfx["transparent"] = color["cyan"]

  load(myspr[plumber], "gfx/plumber.gfx")
  myspr[plumber]["transparent"] = color["cyan"]
  load(myspr[lizard], "gfx/lizard.gfx")
  myspr[lizard]["transparent"] = color["cyan"]
  load(myspr[princess], "gfx/princess.gfx")
  myspr[princess]["transparent"] = color["cyan"]

  # set sprite attributes (position, speed, flipped)
  for (i=0; i<3; i++) {
    switch (int(rand() * 4)) {
      case 0: hflip(myspr[i], myspr[i]); break
      case 1: vflip(myspr[i], myspr[i]); break
    }

    myspr[i]["x"] = int(rand() * (myscr["width"]  - myspr[i]["width"]) )
    myspr[i]["y"] = int(rand() * (myscr["height"] - floor["height"] - myspr[i]["height"]) )
    myspr[i]["dx"] = (int(rand() * 2) == 0) ? -1 : 1
    myspr[i]["dy"] = (int(rand() * 2) == 0) ? -1 : 1
  }

  ## create four (possible horizontally flipped) clouds
  for (i=0; i<4; i++) {
    for (x in cloudgfx) cloud[i][x] = cloudgfx[x]
    if (int(rand() * 4) % 4 == 0) vflip(cloud[i], cloud[i])
    cloud[i]["x"] = rand() * (myscr["width"] + cloud[i]["width"]*2) - cloud[i]["width"]
    cloud[i]["y"] = rand() * (myscr["height"]/4)
    cloud[i]["dx"] = rand() * 0.4 + 0.2
  }

  cursor("off")
  transparent(color["cyan"])
  cls = 1

#  while ("awk" != "difficult") {
#    framenr++
  while (framenr++ < maxframes) {
    # determine location of myscr buffer
    switch ((framenr/100) % 5) {
      case 0: cls = 1; myscr["x"] =  0; myscr["y"] =  0; break; # ( 0, 0) center
      case 1: cls = 1; myscr["x"] =  1; myscr["y"] =  2; break; # ( 1, 1) top left
      case 2: cls = 1; myscr["x"] = -1; myscr["y"] = -1; break; # (-1,-1) bottom right
      case 3: cls = 1; myscr["x"] = -1; myscr["y"] =  2; break; # (-1, 1) top right
      case 4: cls = 1; myscr["x"] =  1; myscr["y"] = -1; break; # ( 1,-1) bottom left
    }

    printf("\033[H")
#    printf("term: %dx%d\n", terminal["width"], terminal["height"]*2)
#    printf("scrn: %dx%d\n", myscr["width"], myscr["height"])
#    printf("spr1: %dx%d (%3dx%3d) [%2d/%2d]\n", myspr[plumber]["width"], myspr[plumber]["height"], myspr[plumber]["x"], myspr[plumber]["y"], myspr[plumber]["dx"], myspr[plumber]["dy"])
#    printf("spr2: %dx%d (%3dx%3d) [%2d/%2d]\n", myspr[lizard]["width"], myspr[lizard]["height"], myspr[lizard]["x"], myspr[lizard]["y"], myspr[lizard]["dx"], myspr[lizard]["dy"])
#    printf("spr3: %dx%d (%3dx%3d) [%2d/%2d]\n", myspr[princess]["width"], myspr[princess]["height"], myspr[princess]["x"], myspr[princess]["y"], myspr[princess]["dx"], myspr[princess]["dy"])

    # clear mysc buffer to bright blue
    clear(myscr, color["brightblue"])

    # draw floor tiles
    for (i=0; i<myscr["width"]/floor["width"]; i++)
      copy(myscr, floor, i*floor["width"], myscr["height"]-floor["height"])
  
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
      copy(myscr, cloud[i], int(cloud[i]["x"]),int(cloud[i]["y"]))
    }

    # move and draw sprites
    for (spr=0; spr<3; spr++) {
      myspr[spr]["x"] += myspr[spr]["dx"]
      myspr[spr]["y"] += myspr[spr]["dy"]
      if ( (myspr[spr]["x"] < -10) || (myspr[spr]["x"] >= (myscr["width"]  - myspr[spr]["width"]) + 10) )  myspr[spr]["dx"] *= -1
      if ( (myspr[spr]["y"] <= -10) || (myspr[spr]["y"] >= (myscr["height"] - floor["height"] - myspr[spr]["height"])) ) myspr[spr]["dy"] *= -1
  
      copy(myscr, myspr[spr], myspr[spr]["x"], myspr[spr]["y"])
    }

    # display myscr buffer on terminal
    draw(myscr, myscr["x"],myscr["y"], cls)

    # add status bar
    frame++
    now = timex()
    if (now > (then+0.5) || cls) {
      pos1 = (myscr["y"] == 0) ? "center" : (myscr["y"] > 0) ? "top" : "bottom"
      pos2 = (myscr["x"] == 0) ? "center" : (myscr["x"] > 0) ? "left" : "right"
      printf("\033[Hframe: %4d/%4d size: %dx%d (%s-%s) fps: %5.2f avg: %5.2f\033[K\n", framenr, maxframes, myscr["width"], myscr["height"], pos1,pos2, frame/(now-then), framenr/(now-start))
      frame = 0
      then = now
    }

    # sleep a bit
    cls = 0
    system("sleep 0.01")
  }

  # save screenshot
  save(myscr, "screen.gfx")

  cursor("on")
  printf("\n")
}

