import gleam/float
import glemy/physics/bounds.{type Bounds}
import glemy/physics/entity.{type Entity}
import glemy/physics/vector2.{type Vector2, Vector2}

pub type Rect {
  Rect(min: Vector2, max: Vector2)
}

pub fn nearest_point(circle_center: Vector2, rect: Rect) -> Vector2 {
  Vector2(
    clamp_axis(circle_center.x, rect.min.x, rect.max.x),
    clamp_axis(circle_center.y, rect.min.y, rect.max.y),
  )
}

fn clamp_axis(x: Float, min: Float, max: Float) -> Float {
  case x <. min, x >. max {
    True, _ -> min
    _, True -> max
    _, _ -> x
  }
}

pub fn overlaps(ball: Entity, rect: Rect) -> Bool {
  vector2.length(vector2.subtract(
    ball.position,
    nearest_point(ball.position, rect),
  ))
  <. ball.radius
}

pub type Axis {
  Horizontal
  Vertical
}

pub fn penetration_axis(ball: Entity, rect: Rect) -> Axis {
  let delta =
    vector2.subtract(ball.position, nearest_point(ball.position, rect))
  case float.absolute_value(delta.x) >=. float.absolute_value(delta.y) {
    True -> Horizontal
    False -> Vertical
  }
}

pub fn to_css(rect: Rect, bounds: Bounds) -> #(Float, Float, Float, Float) {
  let left = bounds.x_fraction(rect.min.x, bounds)
  let right = bounds.x_fraction(rect.max.x, bounds)
  let top = bounds.y_fraction_from_top(rect.max.y, bounds)
  let bottom = bounds.y_fraction_from_top(rect.min.y, bounds)
  #(left, top, right -. left, bottom -. top)
}
