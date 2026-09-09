import glemy/physics/entity.{Entity}
import glemy/physics/vector2.{Vector2}

pub fn integrate_from_rest_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: vector2.zero,
      velocity: vector2.zero,
      radius: 1.0,
    )
  let result = entity.integrate(start, Vector2(0.0, -9.8), 1.0)

  assert result
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, -9.8),
      velocity: Vector2(0.0, -9.8),
      radius: 1.0,
    )
}

pub fn integrate_uses_new_velocity_for_position_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: vector2.zero,
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let result = entity.integrate(start, Vector2(1.0, 0.0), 2.0)

  assert result
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(6.0, 0.0),
      velocity: Vector2(3.0, 0.0),
      radius: 1.0,
    )
}

pub fn integrate_with_zero_dt_is_a_no_op_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 1.0,
    )
  let result = entity.integrate(start, Vector2(5.0, 6.0), 0.0)

  assert result == start
}

pub fn integrate_with_zero_acceleration_moves_at_constant_velocity_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(2.0, -3.0),
      radius: 1.0,
    )
  let result = entity.integrate(start, vector2.zero, 5.0)

  assert result.velocity == Vector2(2.0, -3.0)
  assert result.position == Vector2(10.0, -15.0)
}

pub fn integrate_preserves_radius_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: vector2.zero,
      velocity: vector2.zero,
      radius: 42.5,
    )
  let result = entity.integrate(start, Vector2(1.0, 1.0), 1.0)

  assert result.radius == 42.5
}

pub fn integrate_with_negative_dt_runs_time_backward_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(10.0, 0.0),
      velocity: Vector2(2.0, 0.0),
      radius: 1.0,
    )
  let result = entity.integrate(start, vector2.zero, -1.0)

  assert result.velocity == Vector2(2.0, 0.0)
  assert result.position == Vector2(8.0, 0.0)
}

pub fn integrate_with_a_very_large_dt_does_not_crash_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: vector2.zero,
      velocity: vector2.zero,
      radius: 1.0,
    )
  let result = entity.integrate(start, Vector2(1.0, 0.0), 1_000_000.0)

  assert result.velocity == Vector2(1_000_000.0, 0.0)
  assert result.position == Vector2(1_000_000_000_000.0, 0.0)
}

pub fn integrate_applied_twice_composes_test() {
  let start =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: vector2.zero,
      velocity: vector2.zero,
      radius: 1.0,
    )
  let gravity = Vector2(0.0, -10.0)

  let after_one = entity.integrate(start, gravity, 1.0)
  let after_two = entity.integrate(after_one, gravity, 1.0)

  assert after_two.velocity == Vector2(0.0, -20.0)
  assert after_two.position == Vector2(0.0, -30.0)
}

pub fn loosely_equals_identical_entities_test() {
  let e =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 5.0,
    )
  assert entity.loosely_equals(e, e, 0.0)
}

pub fn loosely_equals_within_tolerance_on_all_fields_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 5.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0001, 2.0001),
      velocity: Vector2(3.0001, 4.0001),
      radius: 5.0001,
    )
  assert entity.loosely_equals(a, b, 0.001)
}

pub fn loosely_equals_false_when_only_position_differs_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 5.0,
    )
  let b = Entity(..a, position: Vector2(1.5, 2.0))
  assert !entity.loosely_equals(a, b, 0.001)
}

pub fn loosely_equals_false_when_only_velocity_differs_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 5.0,
    )
  let b = Entity(..a, velocity: Vector2(3.5, 4.0))
  assert !entity.loosely_equals(a, b, 0.001)
}

pub fn loosely_equals_false_when_only_radius_differs_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 2.0),
      velocity: Vector2(3.0, 4.0),
      radius: 5.0,
    )
  let b = Entity(..a, radius: 5.5)
  assert !entity.loosely_equals(a, b, 0.001)
}

pub fn settle_damps_a_fast_moving_entity_without_snapping_it_test() {
  let moving =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(100.0, 0.0),
      radius: 1.0,
    )

  let settled = entity.settle(moving, 1.0 /. 60.0)

  assert settled.velocity == Vector2(100.0 *. entity.velocity_damping, 0.0)
  assert settled.position == moving.position
}

pub fn settle_snaps_a_slow_entity_to_exactly_zero_test() {
  let slow =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 5.0),
      velocity: Vector2(0.01, 0.0),
      radius: 1.0,
    )

  let settled = entity.settle(slow, 1.0 /. 60.0)

  assert settled.velocity == vector2.zero
}

pub fn settle_leaves_an_already_stationary_entity_stationary_test() {
  let stationary =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 5.0),
      velocity: vector2.zero,
      radius: 1.0,
    )

  assert entity.settle(stationary, 1.0 /. 60.0).velocity == vector2.zero
}

pub fn settle_does_not_snap_a_damped_velocity_exactly_at_the_threshold_test() {
  let raw_speed = entity.rest_velocity_threshold /. entity.velocity_damping
  let right_at_the_boundary =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.0, 0.0),
      velocity: Vector2(raw_speed, 0.0),
      radius: 1.0,
    )

  let settled = entity.settle(right_at_the_boundary, 1.0 /. 60.0)

  assert settled.velocity == Vector2(raw_speed *. entity.velocity_damping, 0.0)
}
