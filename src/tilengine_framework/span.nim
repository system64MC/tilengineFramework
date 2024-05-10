type
  Span*[T] = object
    data: ptr UncheckedArray[T]
    length: int

func newSpan*[T](data: ptr UncheckedArray[T], length: int): Span[T] =
  return Span[T](data: data, length: length)

func `len`*[T](span: Span[T]): int =
  return span.length

func `dataPtr`*[T](span: Span[T]): ptr UncheckedArray[T] =
  return span.data

func `[]`*[T](span: Span[T]; idx: SomeInteger): T =
  return span.data.toOpenArray(0, span.length)[idx]

proc `[]=`*[T](span: Span[T]; idx: SomeInteger, value: T) =
  span.data.toOpenArray(0, span.length)[idx] = T