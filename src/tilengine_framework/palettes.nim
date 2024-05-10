import tilengine
import span

type
  Color* = object
    a*: uint8
    b*: uint8
    g*: uint8
    r*: uint8

type
  Palette* {.byref.} = object
    data: tilengine.Palette # pointer to a Tilengine palette object
    belongsToTilengine: bool # does a Tilengine object own this palette?

proc `=destroy`*(pal: Palette): void =
  if(pal.belongsToTilengine or pal.data == nil): return
  pal.data.delete()
  let p = pal.addr
  p[].data = nil

proc `some`*(pal: Palette): bool =
  return pal.data != nil

proc `isNil`*(pal: Palette): bool =
  return pal.data == nil

proc TLN_TAKE_OWNERSHIP*(pal: ptr Palette) =
  pal.belongsToTilengine = true

func `len`*(palette: Palette): int =
  return getNumColors((palette.data))

func `item`*(palette: Palette): tilengine.Palette =
  return palette.data

func `data`*(palette: Palette): Span[Color] =
  newSpan[Color](
    cast[ptr UncheckedArray[Color]](palette.data.getData(0)),
    palette.data.getNumColors()
  )

proc new*(_: typedesc[Palette], numEntries: SomeInteger): Palette =
  Palette(data: createPalette(numEntries), belongsToTilengine: false)

proc load*(_: typedesc[Palette], filename: string): Palette =
  Palette(data: loadPalette(filename.cstring), belongsToTilengine: false)

proc `data=`*(palette: Palette; data: Span[Color]) =
  let myLen = min(data.len, palette.data.getNumColors)
  let myPtr = cast[ptr UncheckedArray[Color]](palette.data.getData(0))
  copyMem(myPtr, data.dataPtr, myLen * sizeof(Color))

proc `data=`*(palette: Palette; data: openArray[Color]) =
  let myLen = min(data.len, palette.data.getNumColors)
  let myPtr = cast[ptr UncheckedArray[Color]](palette.data.getData(0))
  copyMem(myPtr, data[0].addr, myLen * sizeof(Color))

proc `[]=`*(palette: Palette; idx: int, color: Color) {.inline.} =
  palette.data.setColor(idx, color.r, color.g, color.b)

# TODO : to check, might be buggy
proc `[]`*(palette: Palette; idx: int): Color {.inline.} =
  cast[ptr Color](palette.data.getData(idx))[]

proc `+`*(color1: Color, color2: Color): Color {.inline.} =
  Color(
    r: min(color1.r.uint16 + color2.r.uint16, 255).uint8,
    g: min(color1.g.uint16 + color2.g.uint16, 255).uint8,
    b: min(color1.b.uint16 + color2.b.uint16, 255).uint8,
    )

proc `-`*(color1: Color, color2: Color): Color {.inline.} =
  Color(
    r: max(color1.r.int16 - color2.r.int16, 0).uint8,
    g: max(color1.g.int16 - color2.g.int16, 0).uint8,
    b: max(color1.b.int16 - color2.b.int16, 0).uint8,
    )

proc `mod`*(color1: Color, color2: Color): Color {.inline.} =
  Color(
    r: min((color1.r.uint16 * color2.r.uint16) div 255, 255).uint8,
    g: min((color1.g.uint16 * color2.g.uint16) div 255, 255).uint8,
    b: min((color1.b.uint16 * color2.b.uint16) div 255, 255).uint8,
    )

proc `+=`*(color1: var Color, color2: Color) {.inline.} =
  color1.r = min(color1.r.uint16 + color2.r.uint16, 255).uint8
  color1.g = min(color1.g.uint16 + color2.g.uint16, 255).uint8
  color1.b = min(color1.b.uint16 + color2.b.uint16, 255).uint8

proc `-=`*(color1: var Color, color2: Color) {.inline.} =
  color1.r = max(color1.r.int16 - color2.r.int16, 0).uint8
  color1.g = max(color1.g.int16 - color2.g.int16, 0).uint8
  color1.b = max(color1.b.int16 - color2.b.int16, 0).uint8

proc `%=`*(color1: var Color, color2: Color) {.inline.} =
  color1.r = min((color1.r.uint16 * color2.r.uint16) div 255, 255).uint8
  color1.g = min((color1.g.uint16 * color2.g.uint16) div 255, 255).uint8
  color1.b = min((color1.b.uint16 * color2.b.uint16) div 255, 255).uint8

proc `+`*(palette: Palette, color: Color): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  result.data.addColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)

proc `-`*(palette: Palette, color: Color): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  result.data.subColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)

proc `mod`*(palette: Palette, color: Color): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  result.data.modColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)

proc `+=`*(palette: Palette, color: Color) {.inline.} =
  palette.data.addColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)

proc `-=`*(palette: Palette, color: Color) {.inline.} =
  palette.data.subColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)

proc `%=`*(palette: Palette, color: Color) {.inline.} =
  palette.data.modColor(color.r, color.g, color.b, 0, palette.data.getNumColors().byte)



proc `+`*(palette: Palette, palette2: Palette): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    result[i] = color1 + color2

proc `-`*(palette: Palette, palette2: Palette): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    result[i] = color1 - color2

proc `mod`*(palette: Palette, palette2: Palette): Palette {.inline.} =
  result = Palette(data: palette.data.clone(), belongsToTilengine: false)
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    result[i] = color1 mod color2
    return result

proc `+=`*(palette: Palette, palette2: Palette) {.inline.} =
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    palette[i] = color1 + color2

proc `-=`*(palette: Palette, palette2: Palette) {.inline.} =
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    palette[i] = color1 - color2

proc `%=`*(palette: Palette, palette2: Palette) {.inline.} =
  let len1 = palette.data.getNumColors()
  let len2 = palette2.data.getNumColors()
  for i in 0..<len1:
    var color1 = palette[i]
    var color2 = if(i < len2): palette2[i] else: Color()
    palette[i] = color1 mod color2


proc `&=`*(palette: var Palette, color: Color) {.inline.} =
  if(palette.data.getNumColors() == 256): return
  let pal2 = createPalette(palette.data.getNumColors() + 1)
  for i in 0..<palette.data.getNumColors():
    let cols = palette.data.getData(i)
    pal2.setColor(i, cols[0], cols[1], cols[2])
    pal2.setColor(palette.data.getNumColors, color.r, color.g, color.b)
    palette.data.delete
    palette.data = pal2

proc add*(palette: var Palette, color: Color) {.inline.} =
  if(palette.data.getNumColors() == 256): return
  let pal2 = createPalette(palette.data.getNumColors() + 1)

  for i in 0..<palette.data.getNumColors():
    let cols = palette.data.getData(i)
    pal2.setColor(i, cols[0], cols[1], cols[2])

    pal2.setColor(palette.data.getNumColors, color.r, color.g, color.b)
    palette.data.delete
    palette.data = pal2

proc `&`*(palette: Palette, color: Color): Palette {.inline.} =
  if(palette.data.getNumColors() == 256): return Palette(data: palette.data.clone(), belongsToTilengine: false)
  result = Palette(data: createPalette(palette.data.getNumColors() + 1), belongsToTilengine: false)

  for i in 0..<palette.data.getNumColors():
    let cols = palette.data.getData(i)
    result.data.setColor(i, cols[0], cols[1], cols[2])
    result.data.setColor(palette.data.getNumColors(), color.r, color.g, color.b)

proc resize*(palette: var Palette, length: SomeUnsignedInt) =
  let pal2 = createPalette(length)
  for i in 0..<length:
    if(i < palette.getNumColors()):
      let cols = palette.getData(i)
      pal2.setColor(i, cols[0], cols[1], cols[2])
    else:
      pal2.setColor(i, 0, 0, 0)
      palette.data.delete
      palette.data = pal2

proc `&`*(palette: Palette, palette2: Palette): Palette {.inline.} =
  if(palette.data.getNumColors() == 256): return Palette(data: palette.data.clone(), belongsToTilengine: false)
  # result = createPalette(palette.data.getNumColors() + 1)
  result = Palette(data: createPalette(palette.data.getNumColors() + 1), belongsToTilengine: false)
  for i in 0..<palette.data.getNumColors():
    let cols = palette.data.getData(i)
    result.data.setColor(i, cols[0], cols[1], cols[2])

export tilengine.Palette