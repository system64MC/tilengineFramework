import tilengine
import tilemaps
import bitmaps

type
  LayerImpl = object
    index: int
    bitmap: bitmaps.Bitmap
    tilemap: tilemaps.Tilemap

  Layer* = ref LayerImpl

proc `=destroy`*(layer: LayerImpl): void =
  if(layer.bitmap.item != nil): layer.bitmap.item.delete()
  if(layer.tilemap.item != nil): layer.tilemap.item.delete()

proc TLN_INIT_LAYER*(idx: int): Layer =
  Layer(index: idx, bitmap: TLN_INIT_BITMAP(), tilemap: TLN_INIT_TILEMAP())

proc `tilemap`*(layer: Layer): tilemaps.Tilemap =
  layer.tilemap

proc `tilemap=`*(layer: Layer; tmap: tilemaps.Tilemap) =
  if(layer.tilemap.item != nil): layer.tilemap.item.delete()
  tmap.addr.TLN_TAKE_OWNERSHIP()
  layer.tilemap = tmap
  tilengine.Layer(layer.index).setTilemap(tmap.item)
  if(layer.bitmap.item != nil): layer.bitmap.item.delete()
  layer.bitmap.addr.TLN_TO_NIL()

proc `bitmap`*(layer: Layer): bitmaps.Bitmap =
  layer.bitmap

proc `bitmap=`*(layer: Layer; bmap: bitmaps.Bitmap) =
  if(layer.bitmap.item != nil): layer.bitmap.item.delete()
  bmap.addr.TLN_TAKE_OWNERSHIP()
  layer.bitmap = bmap
  tilengine.Layer(layer.index).setBitmap(bmap.item)
  if(layer.tilemap.item != nil): layer.tilemap.item.delete()
  layer.tilemap.addr.TLN_TO_NIL()

proc setPosition*(layer: Layer, x: SomeInteger, y: SomeInteger) =
  tilengine.Layer(layer.index).setPosition(x.int, y.int)