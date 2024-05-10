import tilengine
import palettes

type
  Tilemap* {.byref.} = object
    data: tilengine.Tilemap # pointer to a Tilengine palette object
    belongsToTilengine: bool # does a Tilengine object own this palette?

proc `=destroy`*(tmap: Tilemap): void =
  if(tmap.belongsToTilengine or tmap.data == nil): return
  tmap.data.delete()
  let p = tmap.addr
  p[].data = nil

proc TLN_TAKE_OWNERSHIP*(tmap: ptr Tilemap) =
  tmap.belongsToTilengine = true

func `item`*(tilemap: Tilemap): tilengine.Tilemap =
  return tilemap.data

proc TLN_TO_NIL*(tilemap: ptr Tilemap) =
  tilemap.data = nil

proc TLN_INIT_TILEMAP*(): Tilemap =
  Tilemap(data: nil, belongsToTilengine: true)

proc new*(_: typedesc[Tilemap], rows, cols: int, tiles: openArray[Tile], bgColor: Color, tileset: Tileset): Tilemap =
  Tilemap(data: createTilemap(rows, cols, cast[ptr UncheckedArray[Color]](tiles[0].addr), cast[uint32](bgColor), tileset))

proc load*(_: typedesc[Tilemap], filename: string): Tilemap =
  Tilemap(data: loadTilemap(filename.cstring), belongsToTilengine: false)

proc `some`*(tmap: Tilemap): bool =
  return tmap.data != nil

proc `isNil`*(tmap: Tilemap): bool =
  return tmap.data == nil