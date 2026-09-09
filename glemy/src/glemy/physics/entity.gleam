import gleam/float
import glemy/physics/vector2.{type Vector2}

pub type Entity {
  Entity(
    position: Vector2,
    velocity: Vector2,
    radius: Float,
    kind: Int,
    resting_time: Float,
  )
}

pub fn integrate(entity: Entity, acceleration: Vector2, dt: Float) -> Entity {
  let velocity = vector2.add(entity.velocity, vector2.scale(acceleration, dt))
  let position = vector2.add(entity.position, vector2.scale(velocity, dt))
  Entity(..entity, position:, velocity:)
}

pub const velocity_damping = 0.997

pub const rest_velocity_threshold = 0.05

pub const sleep_disturbance_velocity = 8.0

pub const sleep_duration = 0.5

pub fn settle(entity: Entity, dt: Float) -> Entity {
  let damped = vector2.scale(entity.velocity, velocity_damping)
  let speed = vector2.length(damped)

  let resting_time = case speed <. sleep_disturbance_velocity {
    True -> float.min(entity.resting_time +. dt, sleep_duration)
    False -> 0.0
  }

  case speed <. rest_velocity_threshold || resting_time >=. sleep_duration {
    True -> Entity(..entity, velocity: vector2.zero, resting_time:)
    False -> Entity(..entity, velocity: damped, resting_time:)
  }
}

pub fn loosely_equals(a: Entity, b: Entity, tolerance: Float) -> Bool {
  vector2.loosely_equals(a.position, b.position, tolerance)
  && vector2.loosely_equals(a.velocity, b.velocity, tolerance)
  && float.loosely_equals(a.radius, b.radius, tolerance)
  && a.kind == b.kind
}
