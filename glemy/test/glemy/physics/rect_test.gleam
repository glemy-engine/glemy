import gleam/float
import glemy/physics/bounds.{Bounds}
import glemy/physics/entity.{type Entity, Entity}
import glemy/physics/rect.{Horizontal, Rect, Vertical}
import glemy/physics/vector2.{type Vector2, Vector2}

const box = Rect(min: Vector2(0.0, 0.0), max: Vector2(10.0, 10.0))

const world_bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(100.0, 100.0))

pub fn nearest_point_inside_the_rect_is_the_point_itself_test() {
  assert rect.nearest_point(Vector2(5.0, 5.0), box) == Vector2(5.0, 5.0)
}

pub fn nearest_point_on_the_edge_is_unchanged_test() {
  assert rect.nearest_point(Vector2(0.0, 5.0), box) == Vector2(0.0, 5.0)
}

pub fn nearest_point_clamps_past_one_axis_only_test() {
  assert rect.nearest_point(Vector2(15.0, 5.0), box) == Vector2(10.0, 5.0)
  assert rect.nearest_point(Vector2(-5.0, 5.0), box) == Vector2(0.0, 5.0)
}

pub fn nearest_point_clamps_both_axes_at_a_corner_test() {
  assert rect.nearest_point(Vector2(15.0, 15.0), box) == Vector2(10.0, 10.0)
  assert rect.nearest_point(Vector2(-5.0, -5.0), box) == Vector2(0.0, 0.0)
}

fn ball_at(position: Vector2, radius: Float) -> Entity {
  Entity(
    position: position,
    velocity: vector2.zero,
    radius: radius,
    kind: 0,
    resting_time: 0.0,
  )
}

pub fn overlaps_when_the_ball_center_is_inside_the_rect_test() {
  assert rect.overlaps(ball_at(Vector2(5.0, 5.0), 1.0), box)
}

pub fn overlaps_when_the_ball_edge_reaches_past_the_rect_test() {
  assert rect.overlaps(ball_at(Vector2(11.5, 5.0), 2.0), box)
}

pub fn does_not_overlap_when_clearly_apart_test() {
  assert !rect.overlaps(ball_at(Vector2(50.0, 50.0), 1.0), box)
}

pub fn does_not_overlap_when_exactly_touching_test() {
  assert !rect.overlaps(ball_at(Vector2(11.0, 5.0), 1.0), box)
}

pub fn does_not_overlap_just_short_of_touching_test() {
  assert !rect.overlaps(ball_at(Vector2(11.01, 5.0), 1.0), box)
}

pub fn overlaps_just_past_touching_test() {
  assert rect.overlaps(ball_at(Vector2(10.99, 5.0), 1.0), box)
}

pub fn penetration_axis_is_horizontal_when_hit_from_the_side_test() {
  assert rect.penetration_axis(ball_at(Vector2(15.0, 5.0), 6.0), box)
    == Horizontal
}

pub fn penetration_axis_is_vertical_when_hit_from_above_test() {
  assert rect.penetration_axis(ball_at(Vector2(5.0, 15.0), 6.0), box)
    == Vertical
}

pub fn penetration_axis_is_vertical_when_hit_from_below_test() {
  assert rect.penetration_axis(ball_at(Vector2(5.0, -5.0), 6.0), box)
    == Vertical
}

pub fn penetration_axis_picks_the_axis_penetrated_further_at_a_corner_test() {
  assert rect.penetration_axis(ball_at(Vector2(15.0, 12.0), 8.0), box)
    == Horizontal
  assert rect.penetration_axis(ball_at(Vector2(12.0, 15.0), 8.0), box)
    == Vertical
}

pub fn penetration_axis_falls_back_to_horizontal_when_exactly_at_the_nearest_point_test() {
  assert rect.penetration_axis(ball_at(Vector2(5.0, 5.0), 1.0), box)
    == Horizontal
}

pub fn to_css_converts_a_world_rect_into_a_css_box_test() {
  let world_rect = Rect(min: Vector2(20.0, 10.0), max: Vector2(40.0, 30.0))

  let #(left, top, width, height) = rect.to_css(world_rect, world_bounds)

  assert left == 0.2
  assert top == 0.7
  assert width == 0.2
  assert float.loosely_equals(height, 0.2, 0.0000001)
}

pub fn to_css_spanning_the_whole_field_is_the_full_box_test() {
  let #(left, top, width, height) =
    rect.to_css(
      Rect(min: world_bounds.min, max: world_bounds.max),
      world_bounds,
    )

  assert left == 0.0
  assert top == 0.0
  assert width == 1.0
  assert height == 1.0
}
