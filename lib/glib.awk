#!/usr/bin/gawk -f

BEGIN {
  color["black"] = 0
  color["red"] = 1
  color["green"] = 2
  color["yellow"] = 3
  color["blue"] = 4
  color["magenta"] = 5
  color["cyan"] = 6
  color["white"] = 7

  color["brightblack"] = 8
  color["brightred"] = 9
  color["brightgreen"] = 10
  color["brightyellow"] = 11
  color["brightblue"] = 12
  color["brightmagenta"] = 13
  color["brightcyan"] = 14
  color["brightwhite"] = 15

  "tput cols"  | getline terminal["width"]
  "tput lines" | getline terminal["height"]

  positive["on"] = 1
  positive["true"] = 1
  positive["yes"] = 1

  negative["off"] = 1
  negative["false"] = 1
  negative["no"] = 1

  config["transparent"] = color["black"]
}

# initialize a graphic buffer
function init(dst, w,h, x,y, dx,dy) {
  dst["width"] = w
  dst["height"] = h

  dst["x"] = x
  dst["y"] = y

  dst["dx"] = dx
  dst["dy"] = dy
}

# turn cursor on or off
function cursor(state) {
  if (state in negative) printf("\033[?25l")
  else if (state in positive) printf("\033[?25h")
}

# clear the terminal
function clearscr() {
  printf("\033[2J")
}

function transparent(col) {
  config["transparent"] = col ? col : color["black"]
}

# reset graphic buffer to single color (default black)
function clear(dst, col,   i, size) {
  size = dst["width"] * dst["height"]

  for (i=0; i<size; i++)
    dst[i] = col ? col : color["black"]
}

# horizontal flip graphic buffer
function hflip(src, dst,   w,h, x,y, sz,i) {
  w = src["width"]
  h = src["height"]
  sz = h*w

  # hflip src into data
  for (y=0; y<h; y++)
    for (x=0; x<w; x++)
      data[(y*w)+x] = src[(h-1-y)*w+x]

  # copy back data to dst
  for (i=0; i<sz; i++) src[i] = data[i]
  delete(data)
}

# vertical flip graphic buffer
function vflip(src, dst,   w,h, x,y, sz,i) {
  w = src["width"]
  h = src["height"]
  sz = h*w

  # vflip src into data
  for (y=0; y<h; y++)
    for (x=0; x<w; x++)
      data[(y*w)+x] = src[y*w+(w-1-x)]

  # copy back data to dst
  for (i=0; i<sz; i++) src[i] = data[i]
  delete(data)
}

# draw graphic buffer to terminal
function draw(scr, xpos, ypos, cls,   screen, line, x,y, w,h, fg,bg, fgprev,bgprev, y_mul_w, y1_mul_w) {
  w = scr["width"]
  h = scr["height"]

  fgprev = bgprev = 0

  # position of zero means center
  if (xpos == 0) xpos = (terminal["width"] - w) / 2
  if (ypos == 0) ypos = (terminal["height"] - h/2) / 2

  # negative position means right aligned
  if (xpos < 0) xpos = (terminal["width"] - w + (xpos+1))
  if (ypos < 0) ypos = (terminal["height"] - h/2 + (ypos+1))

  screen = cls ? "\033[2J" : ""
  for (y=0; y<h; y+=2) {
    y_mul_w = y*w
    y1_mul_w = (y+1)*w

    # set cursor position
    line = sprintf("\033[%0d;%0dH", ypos+(y/2), xpos)

    for (x=0; x<w; x++) {
      fg = (scr[y_mul_w+x] > 7) ? scr[y_mul_w+x] + 82 : scr[y_mul_w+x] + 30
      # for odd-size pictures, add black (bg) pixel at bottom
      bg = (y%2) ? 40 : (scr[y1_mul_w+x] > 7) ? scr[y1_mul_w+x] + 92 : scr[y1_mul_w+x] + 40

      # set forground/background colors and draw pixel(s)
      if ((fg != fgprev) || (bg != bgprev)) {
        line = line "\033[" fg ";" bg "m▀"
        fgprev = fg
        bgprev = bg
      } else line = line "▀"
    }

    screen = screen line
  }
  # draw screen to terminal and reset color
  printf("%s\033[0m", screen)
}

# copy graphic buffer to another graphic buffer (with transparency, and edge clipping)
function copy(dst, src, xpos, ypos, transparent,   srcw,srch, dstw, dsth, x,y, t, col, srcw_mul_y, yposy_mul_dstw, xposx) {
  srcw = src["width"]
  srch = src["height"]

  dstw = dst["width"]
  dsth = dst["height"]

  t = transparent ? transparent : config["transparent"]

  for (y=0; y<srch; y++) {
    # clip image off top/bottom
    if ((ypos + y) >= dsth) break
    if ((ypos + y) < 0) continue
    srcw_mul_y = srcw * y
    yposy_mul_dstw = (ypos + y) * dstw

    for (x=0; x<srcw; x++) {
      xposx = xpos + x

      # clip image on left/right
      if (xposx >= dstw) break
      if (xposx < 0) continue

      # draw non-transparent pixel or else background
      col = src[(srcw_mul_y)+x]
      dst[yposy_mul_dstw + xposx] = (col == t) ? dst[yposy_mul_dstw + xposx] : col
    }
  }
}

# load graphic from file
function load(dst, fname,   w, h, len, data, x, y) {
  # fetch data and determine width and height
  while ((getline < fname) > 0) {
    # skip comments and empty lines
    if ( ($1 ~ /^(#|;)/) || ($1 == "") ) continue
    len = length($0)
    w = (len > w) ? len : w
    data[h++] = $0
  }
  close(fname)

  dst["width"] = w
  dst["height"] = h

  for (y=0; y<h; y++) {
    for (x=0; x<w; x++) {
      # make sure data is in correct range/format
      dst[(y*w)+x] = strtonum("0x"substr(data[y], x+1, 1)) % 16
    }
  }
}

# save graphic buffer to file
function save(src, fname,   w, h, x, y, col, line) {
  w = src["width"]
  h = src["height"]

  printf("# Created on %s by awk-glib\n", strftime()) >fname
  for (y=0; y<h; y++) {
    line = ""
    for (x=0; x<w; x++) {
      col = src[(y*w)+x]
      # convert black to space/" "
      if (col != color["black"]) line = line sprintf("%0X", col)
      else line = line " "
    }
    printf("%s\n", line) >>fname
  }
}

