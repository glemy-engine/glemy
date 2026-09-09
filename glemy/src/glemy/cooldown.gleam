import gleam/float

pub fn tick(remaining: Float, dt: Float) -> Float {
  float.max(0.0, remaining -. dt)
}

pub fn is_ready(remaining: Float) -> Bool {
  remaining <=. 0.0
}
