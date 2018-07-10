## some necessary evil functions of copying sprites from/to semi-multidimensional arrays
function single2multi(sgl, mlt, idx,   i) { for (i in sgl) mlt[idx,i] = sgl[i]; }
function multi2single(mlt, idx, sgl,  i, combined) {
  for (combined in mlt) {
    split(combined, i, SUBSEP)
    if (i[1] == idx) sgl[i[2]] = mlt[i[1],i[2]]
  }
}

BEGIN {
  srand()
  start = then = now = timex()
  maxframes = 200
  targetfps = 20

  plumber = 0
  lizard = 1
  princess = 2

  # set transparent color
  glib["transparent"] = color["cyan"]

  # initialize myscr buffer with size
  chksize(160, 100)
  init(myscr, 160, 100)

  # load sprites
  load(spr, "gfx/plumber.gfx")
  single2multi(spr, myspr, plumber)
  load(spr, "gfx/lizard.gfx")
  single2multi(spr, myspr, lizard)
  load(spr, "gfx/princess.gfx")
  single2multi(spr, myspr, princess)
  load(floorspr,        "gfx/floor.gfx")
  load(cloudspr,        "gfx/cloud.gfx")

  # set sprite attributes (position, speed, flipped)
  for (i=plumber; i<=princess; i++) {
    if ( int(rand() * 4) == 0) {
      multi2single(myspr, i, spr)
      hflip(spr, spr)
      single2multi(spr, myspr, i)
    }
    if ( int(rand() * 4) == 0) {
      multi2single(myspr, i, spr)
      vflip(spr, spr)
      single2multi(spr, myspr, i)
    }

    myspr[i,"x"]  = int(rand() * (myscr["width"]  - myspr[i,"width"]) )
    myspr[i,"y"]  = int(rand() * (myscr["height"] - floorspr["height"] - myspr[i,"height"]) )
    myspr[i,"dx"] = int(rand() * 2) ? -1 : 1
    myspr[i,"dy"] = int(rand() * 2) ? -1 : 1
  }

  # create four (possible horizontally flipped) clouds
  for (i=0; i<4; i++) {
    single2multi(cloudspr, cloud, i)
    if (int(rand() * 4) % 4 == 0) {
      multi2single(cloud, i, spr)
      vflip(spr, spr)
      single2multi(spr, cloud, i)
    }
    cloud[i,"x"] = rand() * (myscr["width"] + cloud[i,"width"]*2) - cloud[i,"width"]
    cloud[i,"y"] = rand() * (myscr["height"]/4)
    cloud[i,"dx"] = rand() * 0.4 + 0.2
  }

  # main loop
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
      cloud[i,"x"] -= cloud[i,"dx"]

      # left off screen
      if (cloud[i,"x"] < (cloud[i,"width"]*-1)) {
        cloud[i,"x"] = myscr["width"]
        cloud[i,"y"] = rand() * (myscr["height"]/4)
        cloud[i,"dx"] = rand() * 0.4 + 0.2
      }
      # right off screen
      if (cloud[i,"x"] > myscr["width"]) {
        cloud[i,"x"] = (cloud[i,"width"]*-1)
        cloud[i,"y"] = rand() * (myscr["height"]/4)
        cloud[i,"dx"] = rand() * 0.4 + 0.2
      }
      # draw cloud to myscr buffer
      multi2single(cloud, i, spr)
      copy(myscr, spr)
    }

    # move and draw sprites
    for (i=plumber; i<=princess; i++) {
      myspr[i,"x"] += myspr[i,"dx"]
      myspr[i,"y"] += myspr[i,"dy"]
      if ( (myspr[i,"x"] < -10) || (myspr[i,"x"] >= (myscr["width"]  - myspr[i,"width"]) + 10) )  myspr[i,"dx"] *= -1
      if ( (myspr[i,"y"] <= -10) || (myspr[i,"y"] >= (myscr["height"] - floorspr["height"] - myspr[i,"height"])) ) myspr[i,"dy"] *= -1
 
      multi2single(myspr, i, spr) 
      copy(myscr, spr)
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
