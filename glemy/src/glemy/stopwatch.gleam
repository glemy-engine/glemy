pub fn tick(elapsed: Float, dt: Float, holding: Bool) -> Float {
  case holding {
    True -> elapsed +. dt
    False -> 0.0
  }
}
