import gleam/float
import glemy/physics/entity.{type Entity, Entity}
import glemy/physics/vector2

pub const restitution = 0.1

pub const genuine_impact_velocity = 15.0

pub fn overlap(a: Entity, b: Entity) -> Float {
  let distance = vector2.length(vector2.subtract(b.position, a.position))
  a.radius +. b.radius -. distance
}

fn mass(e: Entity) -> Float {
  e.radius *. e.radius
}

pub fn resolve(a: Entity, b: Entity) -> #(Entity, Entity) {
  let delta = vector2.subtract(b.position, a.position)
  let distance = vector2.length(delta)
  let overlap = overlap(a, b)

  case overlap >. 0.0 {
    False -> #(a, b)
    True -> {
      let normal = case distance >. 0.0 {
        True -> vector2.scale(delta, 1.0 /. distance)
        False -> vector2.Vector2(1.0, 0.0)
      }

      let mass_a = mass(a)
      let mass_b = mass(b)
      let mass_total = mass_a +. mass_b

      let separation_a = overlap *. mass_b /. mass_total
      let separation_b = overlap *. mass_a /. mass_total
      let a =
        Entity(
          ..a,
          position: vector2.subtract(
            a.position,
            vector2.scale(normal, separation_a),
          ),
        )
      let b =
        Entity(
          ..b,
          position: vector2.add(b.position, vector2.scale(normal, separation_b)),
        )

      let relative_velocity = vector2.subtract(a.velocity, b.velocity)
      let velocity_along_normal = vector2.dot(relative_velocity, normal)

      case velocity_along_normal >. 0.0 {
        False -> #(a, b)
        True -> {
          let effective_restitution =
            restitution
            *. float.min(1.0, velocity_along_normal /. genuine_impact_velocity)
          let impulse_scalar =
            -1.0
            *. { 1.0 +. effective_restitution }
            *. velocity_along_normal
            /. { 1.0 /. mass_a +. 1.0 /. mass_b }
          let a =
            Entity(
              ..a,
              velocity: vector2.add(
                a.velocity,
                vector2.scale(normal, impulse_scalar /. mass_a),
              ),
            )
          let b =
            Entity(
              ..b,
              velocity: vector2.subtract(
                b.velocity,
                vector2.scale(normal, impulse_scalar /. mass_b),
              ),
            )
          #(a, b)
        }
      }
    }
  }
}
