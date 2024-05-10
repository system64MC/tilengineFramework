import tilengine
import palettes

type
  Bitmap* {.byref.} = object
    data: tilengine.Bitmap # pointer to a Tilengine palette object
    belongsToTilengine: bool # does a Tilengine object own this palette?

proc `=destroy`*(bmap: Bitmap): void =
  if(bmap.belongsToTilengine or bmap.data == nil): return
  bmap.data.delete()
  let p = bmap.addr
  p[].data = nil

proc TLN_TAKE_OWNERSHIP*(bmap: ptr Bitmap) =
  bmap.belongsToTilengine = true

func `item`*(bitmap: Bitmap): tilengine.Bitmap =
  return bitmap.data

proc TLN_TO_NIL*(bitmap: ptr Bitmap) =
  bitmap.data = nil

proc TLN_INIT_BITMAP*(): Bitmap =
  Bitmap(data: nil, belongsToTilengine: true)

proc new*(_: typedesc[Bitmap], width, height: int, bpp: int): Bitmap =
  Bitmap(data: createBitmap(width, height, bpp), belongsToTilengine: false)

proc load*(_: typedesc[Bitmap], filename: string): Bitmap =
  Bitmap(data: loadBitmap(filename.cstring), belongsToTilengine: false)

proc `some`*(bmap: Bitmap): bool =
  return bmap.data != nil

proc `isNil`*(bmap: Bitmap): bool =
  return bmap.data == nil