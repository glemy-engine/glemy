import glemy/physics.{Model}
import glemy/physics/bounds.{Bounds}
import glemy/physics/collision
import glemy/physics/collision_sweep.{Bounce}
import glemy/physics/entity.{type Entity, Entity}
import glemy/physics/vector2.{Vector2}

const box = Bounds(min: Vector2(0.0, 0.0), max: Vector2(100.0, 100.0))

fn always_bounce(
  _a: Entity,
  _b: Entity,
) -> collision_sweep.PairInteraction(Nil) {
  Bounce
}

pub fn update_integrates_entities_under_gravity_test() {
  let falling =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(0.0, 0.0),
      radius: 1.0,
    )
  let model =
    Model(entities: [falling], bounds: box, gravity: Vector2(0.0, -9.8))

  let #(updated, _events) =
    physics.update(model, 1.0, bounds.bounce, always_bounce)

  assert updated.entities == [entity.integrate(falling, model.gravity, 1.0)]
}

pub fn update_bounces_entities_off_bounds_test() {
  let escaping =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(2.0, 50.0),
      velocity: Vector2(-15.0, 0.0),
      radius: 1.0,
    )
  let model = Model(entities: [escaping], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 1.0, bounds.bounce, always_bounce)

  let assert [result] = updated.entities
  assert result.position == Vector2(1.0, 50.0)
  assert result.velocity == Vector2(15.0 *. bounds.restitution, 0.0)
}

pub fn update_resolves_collisions_between_entities_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(51.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let model = Model(entities: [a, b], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 0.0, bounds.bounce, always_bounce)

  let expected_pair = collision.resolve(a, b)
  assert updated.entities == [expected_pair.0, expected_pair.1]
}

pub fn update_with_no_entities_is_a_no_op_test() {
  let model = Model(entities: [], bounds: box, gravity: Vector2(0.0, -9.8))

  let #(updated, _events) =
    physics.update(model, 1.0, bounds.bounce, always_bounce)

  assert updated.entities == []
}

pub fn update_with_a_single_entity_has_no_pair_to_collide_with_test() {
  let lone =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(3.0, 4.0),
      radius: 1.0,
    )
  let model = Model(entities: [lone], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 1.0, bounds.bounce, always_bounce)

  assert updated.entities == [entity.integrate(lone, model.gravity, 1.0)]
}

pub fn update_resolves_every_pair_among_three_entities_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(10.0, 10.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(11.5, 10.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let c =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(90.0, 90.0),
      velocity: Vector2(0.0, 0.0),
      radius: 1.0,
    )
  let model = Model(entities: [a, b, c], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 0.0, bounds.bounce, always_bounce)

  let expected_pair = collision.resolve(a, b)
  assert updated.entities == [expected_pair.0, expected_pair.1, c]
}

pub fn update_resolves_every_pair_among_four_entities_in_sequence_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(51.5, 50.0),
      velocity: vector2.zero,
      radius: 1.0,
    )
  let c =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(53.0, 50.0),
      velocity: vector2.zero,
      radius: 1.0,
    )
  let d =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(54.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let model = Model(entities: [a, b, c, d], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 0.0, bounds.bounce, always_bounce)

  let #(a1, b1) = collision.resolve(a, b)
  let #(a2, c1) = collision.resolve(a1, c)
  let #(a3, d1) = collision.resolve(a2, d)
  let #(b2, c2) = collision.resolve(b1, c1)
  let #(b3, d2) = collision.resolve(b2, d1)
  let #(c3, d3) = collision.resolve(c2, d2)

  assert updated.entities == [a3, b3, c3, d3]
}

pub fn update_collides_entities_using_positions_after_bouncing_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(5.0, 50.0),
      velocity: Vector2(-20.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(1.5, 50.0),
      velocity: vector2.zero,
      radius: 1.0,
    )
  let model = Model(entities: [a, b], bounds: box, gravity: vector2.zero)

  let #(updated, _events) =
    physics.update(model, 1.0, bounds.bounce, always_bounce)

  let a_after_bounce =
    Entity(
      resting_time: 0.0,
      kind: 5,
      position: Vector2(1.0, 50.0),
      velocity: Vector2(20.0 *. bounds.restitution, 0.0),
      radius: 1.0,
    )
  let expected_pair = collision.resolve(a_after_bounce, b)
  assert updated.entities == [expected_pair.0, expected_pair.1]
}

pub fn spawn_entity_adds_a_new_entity_test() {
  let existing =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 1.0),
      velocity: Vector2(2.0, 2.0),
      radius: 3.0,
    )
  let model = Model(entities: [existing], bounds: box, gravity: vector2.zero)
  let new_entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: vector2.zero,
      radius: 4.0,
    )

  let updated = physics.spawn_entity(model, new_entity)

  assert updated.entities == [new_entity, existing]
  assert updated.bounds == model.bounds
  assert updated.gravity == model.gravity
}

pub fn spawn_entity_into_an_empty_model_test() {
  let model = Model(entities: [], bounds: box, gravity: vector2.zero)
  let new_entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(10.0, 10.0),
      velocity: vector2.zero,
      radius: 4.0,
    )

  let updated = physics.spawn_entity(model, new_entity)

  assert updated.entities == [new_entity]
}

pub fn entity_count_of_an_empty_model_is_zero_test() {
  let model = Model(entities: [], bounds: box, gravity: vector2.zero)

  assert physics.entity_count(model) == 0
}

pub fn entity_count_counts_every_entity_test() {
  let one =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 1.0),
      velocity: vector2.zero,
      radius: 1.0,
    )
  let two =
    Entity(
      resting_time: 0.0,
      kind: 1,
      position: Vector2(2.0, 2.0),
      velocity: vector2.zero,
      radius: 1.0,
    )
  let model = Model(entities: [one, two], bounds: box, gravity: vector2.zero)

  assert physics.entity_count(model) == 2
}

pub fn settle_all_applies_settle_to_every_entity_test() {
  let resting =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 1.0),
      velocity: Vector2(0.0, 0.001),
      radius: 1.0,
    )
  let moving =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(2.0, 2.0),
      velocity: Vector2(5.0, 5.0),
      radius: 1.0,
    )
  let model =
    Model(entities: [resting, moving], bounds: box, gravity: vector2.zero)

  let updated = physics.settle_all(model, 1.0 /. 60.0)

  assert updated.entities
    == [entity.settle(resting, 1.0 /. 60.0), entity.settle(moving, 1.0 /. 60.0)]
}

pub fn settle_all_on_no_entities_is_a_noop_test() {
  let model = Model(entities: [], bounds: box, gravity: vector2.zero)

  let updated = physics.settle_all(model, 1.0 /. 60.0)

  assert updated.entities == []
}

pub fn settle_all_leaves_bounds_and_gravity_unchanged_test() {
  let entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 1.0),
      velocity: Vector2(5.0, 5.0),
      radius: 1.0,
    )
  let model =
    Model(entities: [entity], bounds: box, gravity: Vector2(0.0, -9.8))

  let updated = physics.settle_all(model, 1.0 /. 60.0)

  assert updated.bounds == model.bounds
  assert updated.gravity == model.gravity
}
