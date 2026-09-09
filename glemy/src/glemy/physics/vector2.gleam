import gleam/float

pub type Vector2 {
  Vector2(x: Float, y: Float)
}

pub const zero = Vector2(0.0, 0.0)

pub fn add(a: Vector2, b: Vector2) -> Vector2 {
  Vector2(a.x +. b.x, a.y +. b.y)
}

pub fn subtract(a: Vector2, b: Vector2) -> Vector2 {
  Vector2(a.x -. b.x, a.y -. b.y)
}

pub fn scale(v: Vector2, scalar: Float) -> Vector2 {
  Vector2(v.x *. scalar, v.y *. scalar)
}

pub fn dot(a: Vector2, b: Vector2) -> Float {
  a.x *. b.x +. a.y *. b.y
}

pub fn length_squared(v: Vector2) -> Float {
  dot(v, v)
}

pub fn length(v: Vector2) -> Float {
  let assert Ok(result) = float.square_root(length_squared(v))
  result
}

pub fn loosely_equals(a: Vector2, b: Vector2, tolerance: Float) -> Bool {
  float.loosely_equals(a.x, b.x, tolerance)
  && float.loosely_equals(a.y, b.y, tolerance)
}
