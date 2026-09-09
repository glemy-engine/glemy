import glemy/physics/collision
import glemy/physics/collision_sweep.{Bounce, Consume}
import glemy/physics/entity.{type Entity, Entity}
import glemy/physics/vector2.{Vector2}

fn always_bounce(
  _a: Entity,
  _b: Entity,
) -> collision_sweep.PairInteraction(Nil) {
  Bounce
}

fn merge_same_kind(
  a: Entity,
  b: Entity,
) -> collision_sweep.PairInteraction(Int) {
  case collision.overlap(a, b) >. 0.0 && a.kind == b.kind {
    True ->
      Consume(
        Entity(
          position: vector2.scale(vector2.add(a.position, b.position), 0.5),
          velocity: vector2.scale(vector2.add(a.velocity, b.velocity), 0.5),
          radius: a.radius,
          kind: a.kind + 1,
          resting_time: 0.0,
        ),
        a.kind,
      )
    False -> Bounce
  }
}

pub fn resolve_all_collisions_with_no_entities_is_a_no_op_test() {
  assert collision_sweep.resolve_all_collisions([], always_bounce) == #([], [])
}

pub fn resolve_all_collisions_with_a_single_entity_has_no_pair_to_collide_with_test() {
  let lone =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(3.0, 4.0),
      radius: 1.0,
    )

  assert collision_sweep.resolve_all_collisions([lone], always_bounce)
    == #([lone], [])
}

pub fn resolve_all_collisions_bounces_when_interact_always_says_bounce_test() {
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
      position: Vector2(52.0, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved, events) =
    collision_sweep.resolve_all_collisions([a, b], always_bounce)

  let expected_pair = collision.resolve(a, b)
  assert resolved == [expected_pair.0, expected_pair.1]
  assert events == []
}

pub fn resolve_all_collisions_bounces_a_different_kind_pair_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 1,
      position: Vector2(51.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved, events) =
    collision_sweep.resolve_all_collisions([a, b], merge_same_kind)

  let expected_pair = collision.resolve(a, b)
  assert resolved == [expected_pair.0, expected_pair.1]
  assert events == []
}

pub fn resolve_all_collisions_consumes_two_overlapping_same_kind_entities_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(51.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved, events) =
    collision_sweep.resolve_all_collisions([a, b], merge_same_kind)

  let assert [merged] = resolved
  assert merged.kind == 1
  assert merged.position == Vector2(50.75, 50.0)
  assert events == [0]
}

pub fn resolve_all_collisions_consumes_only_the_first_pair_in_a_three_way_same_kind_cluster_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(51.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let c =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(53.0, 50.0),
      velocity: vector2.zero,
      radius: 1.0,
    )

  let #(resolved, events) =
    collision_sweep.resolve_all_collisions([a, b, c], merge_same_kind)

  let assert [merged, untouched] = resolved
  assert merged.kind == 1
  assert untouched == c
  assert events == [0]
}

pub fn resolve_all_collisions_collects_events_from_multiple_consumes_in_one_pass_test() {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(20.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(21.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )
  let c =
    Entity(
      resting_time: 0.0,
      kind: 2,
      position: Vector2(50.0, 50.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )
  let d =
    Entity(
      resting_time: 0.0,
      kind: 2,
      position: Vector2(51.5, 50.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let #(resolved, events) =
    collision_sweep.resolve_all_collisions([a, b, c, d], merge_same_kind)

  let assert [merged_ab, merged_cd] = resolved
  assert merged_ab.kind == 1
  assert merged_cd.kind == 3
  assert events == [0, 2]
}
