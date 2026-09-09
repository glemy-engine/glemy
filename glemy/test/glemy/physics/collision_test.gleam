import gleam/float
import glemy/physics/collision
import glemy/physics/entity.{Entity}
import glemy/physics/vector2.{Vector2}

pub fn not_overlapping_is_a_no_op_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(10.0, 0.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  assert collision.resolve(a, b) == #(a, b)
}

pub fn head_on_equal_mass_collision_swaps_velocities_proportionally_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(20.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(-20.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = 40.0
  let effective_restitution =
    collision.restitution
    *. float.min(
      1.0,
      velocity_along_normal /. collision.genuine_impact_velocity,
    )
  let impulse_scalar =
    -1.0
    *. { 1.0 +. effective_restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(20.0 +. impulse_scalar /. 1.0, 0.0)
  assert resolved_b.velocity == Vector2(-20.0 -. impulse_scalar /. 1.0, 0.0)
  assert resolved_a.position == Vector2(-0.25, 0.0)
  assert resolved_b.position == Vector2(1.75, 0.0)
}

pub fn overlapping_but_separating_corrects_position_not_velocity_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  assert resolved_a.velocity == a.velocity
  assert resolved_b.velocity == b.velocity
  assert resolved_a.position == Vector2(-0.25, 0.0)
  assert resolved_b.position == Vector2(1.75, 0.0)
}

pub fn coincident_positions_use_a_fallback_normal_instead_of_crashing_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(3.0, 3.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(3.0, 3.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  assert resolved_a.position != resolved_b.position
}

pub fn oblique_collision_only_reflects_the_along_normal_component_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(10.0, 5.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(-10.0, -3.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = 20.0
  let effective_restitution =
    collision.restitution
    *. float.min(
      1.0,
      velocity_along_normal /. collision.genuine_impact_velocity,
    )
  let impulse_scalar =
    -1.0
    *. { 1.0 +. effective_restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(10.0 +. impulse_scalar /. 1.0, 5.0)
  assert resolved_b.velocity == Vector2(-10.0 -. impulse_scalar /. 1.0, -3.0)
}

pub fn collision_along_the_y_axis_works_the_same_as_x_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(0.0, 20.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 1.5),
      velocity: Vector2(0.0, -20.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = 40.0
  let effective_restitution =
    collision.restitution
    *. float.min(
      1.0,
      velocity_along_normal /. collision.genuine_impact_velocity,
    )
  let impulse_scalar =
    -1.0
    *. { 1.0 +. effective_restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(0.0, 20.0 +. impulse_scalar /. 1.0)
  assert resolved_b.velocity == Vector2(0.0, -20.0 -. impulse_scalar /. 1.0)
  assert resolved_a.position == Vector2(0.0, -0.25)
  assert resolved_b.position == Vector2(0.0, 1.75)
}

pub fn purely_tangential_motion_separates_position_but_not_velocity_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(0.0, 5.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(0.0, -3.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  assert resolved_a.velocity == a.velocity
  assert resolved_b.velocity == b.velocity
  assert resolved_a.position == Vector2(-0.25, 0.0)
  assert resolved_b.position == Vector2(1.75, 0.0)
}

pub fn zero_radius_entities_never_collide_even_when_coincident_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(3.0, 3.0),
      velocity: Vector2(1.0, 0.0),
      radius: 0.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(3.0, 3.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 0.0,
    )

  assert collision.resolve(a, b) == #(a, b)
}

pub fn asymmetric_radii_separate_positions_weighted_by_mass_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(10.0, 0.0),
      radius: 5.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(4.0, 0.0),
      velocity: Vector2(-10.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let separation_a = 2.0 *. 1.0 /. 26.0
  let separation_b = 2.0 *. 25.0 /. 26.0
  assert resolved_a.position == Vector2(0.0 -. separation_a, 0.0)
  assert resolved_b.position == Vector2(4.0 +. separation_b, 0.0)

  let velocity_along_normal = 20.0
  let effective_restitution =
    collision.restitution
    *. float.min(
      1.0,
      velocity_along_normal /. collision.genuine_impact_velocity,
    )
  let impulse_scalar =
    -1.0
    *. { 1.0 +. effective_restitution }
    *. velocity_along_normal
    /. { 1.0 /. 25.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(10.0 +. impulse_scalar /. 25.0, 0.0)
  assert resolved_b.velocity == Vector2(-10.0 -. impulse_scalar /. 1.0, 0.0)
}

pub fn unequal_mass_collision_conserves_momentum_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(9.0, 0.0),
      radius: 4.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(3.0, 0.0),
      velocity: Vector2(-6.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let mass_a = 4.0 *. 4.0
  let mass_b = 1.0 *. 1.0
  let momentum_before = mass_a *. a.velocity.x +. mass_b *. b.velocity.x
  let momentum_after =
    mass_a *. resolved_a.velocity.x +. mass_b *. resolved_b.velocity.x
  assert float.loosely_equals(momentum_before, momentum_after, 0.0001)
}

pub fn deep_penetration_still_separates_to_exactly_touching_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: vector2.zero,
      radius: 5.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 0.0),
      velocity: vector2.zero,
      radius: 5.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  assert resolved_a.position == Vector2(-4.5, 0.0)
  assert resolved_b.position == Vector2(5.5, 0.0)
  assert vector2.length(vector2.subtract(
      resolved_b.position,
      resolved_a.position,
    ))
    == 10.0
}

pub fn collision_softens_a_slow_approach_below_genuine_impact_velocity_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = 2.0
  let effective_restitution =
    collision.restitution
    *. float.min(
      1.0,
      velocity_along_normal /. collision.genuine_impact_velocity,
    )
  let impulse_scalar =
    -1.0
    *. { 1.0 +. effective_restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(1.0 +. impulse_scalar /. 1.0, 0.0)
  assert resolved_b.velocity == Vector2(-1.0 -. impulse_scalar /. 1.0, 0.0)
  assert resolved_a.position == Vector2(-0.25, 0.0)
  assert resolved_b.position == Vector2(1.75, 0.0)
}

pub fn collision_at_exactly_genuine_impact_velocity_uses_full_restitution_test() {
  let half = collision.genuine_impact_velocity /. 2.0
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(half, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(float.negate(half), 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = collision.genuine_impact_velocity
  let impulse_scalar =
    -1.0
    *. { 1.0 +. collision.restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(half +. impulse_scalar /. 1.0, 0.0)
  assert resolved_b.velocity
    == Vector2(float.negate(half) -. impulse_scalar /. 1.0, 0.0)
}

pub fn collision_never_exceeds_base_restitution_on_a_very_fast_impact_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(1000.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.5, 0.0),
      velocity: Vector2(-1000.0, 0.0),
      radius: 1.0,
    )

  let #(resolved_a, resolved_b) = collision.resolve(a, b)

  let velocity_along_normal = 2000.0
  let impulse_scalar =
    -1.0
    *. { 1.0 +. collision.restitution }
    *. velocity_along_normal
    /. { 1.0 /. 1.0 +. 1.0 /. 1.0 }
  assert resolved_a.velocity == Vector2(1000.0 +. impulse_scalar /. 1.0, 0.0)
  assert resolved_b.velocity == Vector2(-1000.0 -. impulse_scalar /. 1.0, 0.0)
}
