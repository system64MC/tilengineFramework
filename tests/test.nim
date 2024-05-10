import ../src/tilengine_framework/context
import ../src/tilengine_framework/tilemaps
import ../src/tilengine_framework/layers

proc main() =
  let c = Context.init(256, 224, numPalettesEntries = 16)
  let tmap = Tilemap.load("./assets/sonic/Sonic_md_fg1.tmx")
  let tmap2 = Tilemap.load("./assets/sonic/Sonic_md_bg1.tmx")
  c.layers[0].tilemap = tmap

  c.rasterCallback = (
    proc(line: int32) = c.layers[0].setPosition(line, 0)
    )

  var frame = 0

  Window.open(scale = 2)
  while(Window.process):
    Window.draw()
    frame.inc
    if(frame == 600):
      c.layers[0].tilemap = tmap2

main()