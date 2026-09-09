import gleam/float
import glemy/physics/entity.{type Entity, Entity}
import glemy/physics/vector2.{type Vector2, Vector2}

pub type Bounds {
  Bounds(min: Vector2, max: Vector2)
}

pub fn bounce(entity: Entity, bounds: Bounds) -> Entity {
  let #(x, vx) =
    resolve_axis(
      entity.position.x,
      entity.velocity.x,
      bounds.min.x +. entity.radius,
      bounds.max.x -. entity.radius,
      fn(v) { reflected_speed(v, positive: True) },
      fn(v) { reflected_speed(v, positive: False) },
    )
  let #(y, vy) =
    resolve_axis(
      entity.position.y,
      entity.velocity.y,
      bounds.min.y +. entity.radius,
      bounds.max.y -. entity.radius,
      fn(v) { reflected_speed(v, positive: True) },
      fn(v) { reflected_speed(v, positive: False) },
    )
  Entity(..entity, position: Vector2(x, y), velocity: Vector2(vx, vy))
}

pub const restitution = 0.1

pub const genuine_impact_velocity = 15.0

pub fn resolve_axis(
  position: Float,
  velocity: Float,
  min: Float,
  max: Float,
  on_low: fn(Float) -> Float,
  on_high: fn(Float) -> Float,
) -> #(Float, Float) {
  case position <. min, position >. max {
    True, _ -> #(min, on_low(velocity))
    _, True -> #(max, on_high(velocity))
    _, _ -> #(position, velocity)
  }
}

pub fn resolve_high_only(
  position: Float,
  velocity: Float,
  max: Float,
  on_high: fn(Float) -> Float,
) -> #(Float, Float) {
  case position >. max {
    True -> #(max, on_high(velocity))
    False -> #(position, velocity)
  }
}

fn reflected_speed(velocity: Float, positive positive: Bool) -> Float {
  let speed = float.absolute_value(velocity)
  let restitution_scale =
    restitution *. float.min(1.0, speed /. genuine_impact_velocity)
  let reflected = speed *. restitution_scale
  case reflected == 0.0, positive {
    True, _ -> 0.0
    False, True -> reflected
    False, False -> float.negate(reflected)
  }
}

pub fn clamp_x(x: Float, radius: Float, bounds: Bounds) -> Float {
  clamp_axis(x, bounds.min.x +. radius, bounds.max.x -. radius)
}

fn clamp_axis(position: Float, min: Float, max: Float) -> Float {
  case position <. min, position >. max {
    True, _ -> min
    _, True -> max
    _, _ -> position
  }
}

pub fn x_from_canvas_pixel(
  pixel_x: Float,
  canvas_width: Float,
  bounds: Bounds,
) -> Float {
  let fraction = pixel_x /. canvas_width
  bounds.min.x +. fraction *. { bounds.max.x -. bounds.min.x }
}

pub fn y_fraction_from_top(world_y: Float, bounds: Bounds) -> Float {
  { bounds.max.y -. world_y } /. { bounds.max.y -. bounds.min.y }
}

pub fn x_fraction(world_x: Float, bounds: Bounds) -> Float {
  { world_x -. bounds.min.x } /. { bounds.max.x -. bounds.min.x }
}
