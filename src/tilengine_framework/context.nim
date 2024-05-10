import tilengine
import palettes
import tilemaps
import bitmaps
import layers

type
  Layers* = ref object
    data: array[16, layers.Layer]

  Palettes* = object
  Sprites* = object
  Window* = object

  RasterCallback* = proc(line: int32): void
  FrameCallback* = proc(frame: int32): void

  ContextImpl = object
    numLayers: int
    numAnims: int
    numSprites: int
    hres: int
    vres: int
    paletteEntries: int
    palettes*: Palettes
    # palettesImpl: array[8, palettes.Palette]
    layerList: Layers
    engine: Engine
    rCallback: RasterCallback
    fCallback: FrameCallback

  Context* = ref ContextImpl

proc `=destroy`*(context: ContextImpl): void =
  for i in 0..<8:
    # setGlobalPalette(i, nil)
    try:
      let pal = getGlobalPalette(i)
      if(pal != nil): pal.delete()
    except: continue
  
var internalContext: Context

proc rastCallback(line: int32) {.cdecl.} =
  if(internalContext.rCallback == nil): return
  internalContext.rCallback(line)

proc frameCallback(frame: int32): void {.cdecl.} =
  if(internalContext.fCallback == nil): return
  internalContext.fCallback(frame)

proc `[]`*(pals: Palettes; idx: SomeInteger): palettes.Palette =
  return palettes.Palette(data: getGlobalPalette(idx), belongsToTilengine: true)

proc `[]=`*(pals: Palettes; idx: SomeInteger, value: palettes.Palette) =
  let pal = getGlobalPalette(idx)
  let len = min(pal.getNumEntries(), value.item.getNumEntries())
  copyMem(pal.getData(), value.item.getData(), len * 4)
  return palettes.Palette(data: getGlobalPalette(idx), belongsToTilengine: true)

proc init*(_: typedesc[Context], hres, vres: int, numLayers: range[1..16] = 4, numSprites: range[1..256] = 64, numAnims: range[1..256] = 64, numPalettesEntries: range[1..256] = 16): Context =
  result = Context(
    numLayers: numLayers,
    numAnims: numAnims,
    hres: hres,
    vres: vres,
    paletteEntries: numPalettesEntries,
    layerList: Layers(),
    palettes: Palettes(),
    engine: tilengine.init(hres, vres, numLayers, numSprites, numAnims),
  )

  for i in 0..<numLayers:
    result.layerList.data[i]= TLN_INIT_LAYER(i)

  setRasterCallback(rastCallback)
  setFrameCallback(frameCallback)

  # for i in 0..<8:
    # let pal = palettes.Palette.new(numPalettesEntries)
    # pal.addr.TLN_TAKE_OWNERSHIP()
    # result.palettesImpl[i] = pal
    # let pal = createPalette(numPalettesEntries)
    # setGlobalPalette(i, pal)

  internalContext = result

proc `[]`*(lays: Layers; idx: SomeInteger): layers.Layer =
  lays.data[idx]

proc open*(_: typedesc[Window], overlay: string = ""; scale: range[0..5] = 0; flags: set[CreateWindowFlag] = {}) =
  createWindow(if overlay == "": nil else: overlay.cstring, scale, flags)

func `active`*(_:typedesc[Window]): bool =
  isWindowActive()

func `process`*(_:typedesc[Window]): bool =
  processWindow()

func draw*(_:typedesc[Window], frame: int = 0) =
  drawFrame(frame)

proc `rasterCallback=`*(context: Context; cb: RasterCallback) =
  context.rCallback = cb

proc `frameCallback=`*(context: Context; cb: FrameCallback) =
  context.fCallback = cb

func `layers`*(context: Context): Layers =
  context.layerList