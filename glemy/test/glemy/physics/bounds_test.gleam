import gleam/float
import glemy/physics/bounds.{Bounds}
import glemy/physics/entity.{Entity}
import glemy/physics/vector2.{Vector2}

const box = Bounds(min: Vector2(0.0, 0.0), max: Vector2(10.0, 10.0))

pub fn inside_bounds_is_unchanged_test() {
  let inside =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 5.0),
      velocity: Vector2(1.0, -1.0),
      radius: 1.0,
    )

  assert bounds.bounce(inside, box) == inside
}

pub fn on_the_edge_is_unchanged_test() {
  let on_edge =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 9.0),
      velocity: Vector2(0.0, 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(on_edge, box) == on_edge
}

pub fn bounces_off_the_min_x_edge_test() {
  let past_min_x =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-1.0, 5.0),
      velocity: Vector2(-50.0, 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(past_min_x, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(5.0, 0.0),
      radius: 1.0,
    )
}

pub fn bounces_off_the_max_x_edge_test() {
  let past_max_x =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(11.0, 5.0),
      velocity: Vector2(50.0, 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(past_max_x, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(9.0, 5.0),
      velocity: Vector2(-5.0, 0.0),
      radius: 1.0,
    )
}

pub fn bounces_off_the_min_y_edge_test() {
  let past_min_y =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, -1.0),
      velocity: Vector2(0.0, -50.0),
      radius: 1.0,
    )

  assert bounds.bounce(past_min_y, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 1.0),
      velocity: Vector2(0.0, 5.0),
      radius: 1.0,
    )
}

pub fn bounces_off_the_max_y_edge_test() {
  let past_max_y =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 11.0),
      velocity: Vector2(0.0, 50.0),
      radius: 1.0,
    )

  assert bounds.bounce(past_max_y, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 9.0),
      velocity: Vector2(0.0, -5.0),
      radius: 1.0,
    )
}

pub fn bounces_off_a_corner_on_both_axes_at_once_test() {
  let past_corner =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-1.0, -1.0),
      velocity: Vector2(-50.0, -50.0),
      radius: 1.0,
    )

  assert bounds.bounce(past_corner, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 1.0),
      velocity: Vector2(5.0, 5.0),
      radius: 1.0,
    )
}

pub fn velocity_pointing_inward_is_still_corrected_to_point_inward_test() {
  let overshot =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-5.0, 5.0),
      velocity: Vector2(50.0, 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(overshot, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(5.0, 0.0),
      radius: 1.0,
    )
}

pub fn exactly_at_min_moving_outward_is_not_bounced_this_frame_test() {
  let at_edge =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(-3.0, 0.0),
      radius: 1.0,
    )
  assert bounds.bounce(at_edge, box) == at_edge
}

pub fn exactly_at_max_moving_outward_is_not_bounced_this_frame_test() {
  let at_edge =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(9.0, 5.0),
      velocity: Vector2(3.0, 0.0),
      radius: 1.0,
    )
  assert bounds.bounce(at_edge, box) == at_edge
}

pub fn larger_radius_entities_bounce_sooner_test() {
  let large_radius_near_edge =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(9.9, 5.0),
      velocity: Vector2(50.0, 0.0),
      radius: 5.0,
    )

  assert bounds.bounce(large_radius_near_edge, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 5.0),
      velocity: Vector2(-5.0, 0.0),
      radius: 5.0,
    )
}

pub fn bounce_softens_a_gentle_impact_below_genuine_impact_velocity_test() {
  let gently_resting =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-1.0, 5.0),
      velocity: Vector2(-1.0, 0.0),
      radius: 1.0,
    )

  let restitution_scale =
    bounds.restitution *. float.min(1.0, 1.0 /. bounds.genuine_impact_velocity)
  let expected_speed = 1.0 *. restitution_scale
  assert bounds.bounce(gently_resting, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(expected_speed, 0.0),
      radius: 1.0,
    )
}

pub fn bounce_softening_still_clamps_position_on_the_max_edge_test() {
  let gently_resting =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(11.0, 5.0),
      velocity: Vector2(1.0, 0.0),
      radius: 1.0,
    )

  let restitution_scale =
    bounds.restitution *. float.min(1.0, 1.0 /. bounds.genuine_impact_velocity)
  let expected_speed = 1.0 *. restitution_scale
  assert bounds.bounce(gently_resting, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(9.0, 5.0),
      velocity: Vector2(float.negate(expected_speed), 0.0),
      radius: 1.0,
    )
}

pub fn bounce_at_exactly_genuine_impact_velocity_uses_full_restitution_test() {
  let at_the_reference_speed =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-1.0, 5.0),
      velocity: Vector2(float.negate(bounds.genuine_impact_velocity), 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(at_the_reference_speed, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(
        bounds.genuine_impact_velocity *. bounds.restitution,
        0.0,
      ),
      radius: 1.0,
    )
}

pub fn bounce_never_exceeds_base_restitution_on_a_very_fast_impact_test() {
  let very_fast =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(-1.0, 5.0),
      velocity: Vector2(-1000.0, 0.0),
      radius: 1.0,
    )

  assert bounds.bounce(very_fast, box)
    == Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(1.0, 5.0),
      velocity: Vector2(1000.0 *. bounds.restitution, 0.0),
      radius: 1.0,
    )
}

pub fn zero_velocity_past_the_edge_still_clamps_position_test() {
  let past_max_at_rest =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(11.0, 5.0),
      velocity: Vector2(0.0, 0.0),
      radius: 1.0,
    )
  let result = bounds.bounce(past_max_at_rest, box)
  assert result.position == Vector2(9.0, 5.0)
  assert vector2.loosely_equals(result.velocity, vector2.zero, 0.0001)
}

pub fn degenerate_zero_size_bounds_still_clamps_without_crashing_test() {
  let point_box = Bounds(min: Vector2(5.0, 5.0), max: Vector2(5.0, 5.0))
  let outside =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(10.0, 10.0),
      velocity: Vector2(1.0, 1.0),
      radius: 1.0,
    )
  let result = bounds.bounce(outside, point_box)
  assert result.position == Vector2(4.0, 4.0)
}

pub fn x_from_canvas_pixel_left_edge_maps_to_bounds_min_x_test() {
  assert bounds.x_from_canvas_pixel(0.0, 512.0, box) == 0.0
}

pub fn x_from_canvas_pixel_right_edge_maps_to_bounds_max_x_test() {
  assert bounds.x_from_canvas_pixel(512.0, 512.0, box) == 10.0
}

pub fn x_from_canvas_pixel_center_maps_to_the_midpoint_test() {
  assert bounds.x_from_canvas_pixel(256.0, 512.0, box) == 5.0
}

pub fn x_from_canvas_pixel_is_linear_across_the_width_test() {
  assert bounds.x_from_canvas_pixel(128.0, 512.0, box) == 2.5
  assert bounds.x_from_canvas_pixel(384.0, 512.0, box) == 7.5
}

pub fn x_from_canvas_pixel_respects_a_non_zero_bounds_origin_test() {
  let offset_box = Bounds(min: Vector2(100.0, 0.0), max: Vector2(200.0, 10.0))
  assert bounds.x_from_canvas_pixel(0.0, 512.0, offset_box) == 100.0
  assert bounds.x_from_canvas_pixel(512.0, 512.0, offset_box) == 200.0
  assert bounds.x_from_canvas_pixel(256.0, 512.0, offset_box) == 150.0
}

pub fn x_from_canvas_pixel_does_not_clamp_out_of_range_pixels_test() {
  assert bounds.x_from_canvas_pixel(-256.0, 512.0, box) == -5.0
  assert bounds.x_from_canvas_pixel(768.0, 512.0, box) == 15.0
}

pub fn y_fraction_from_top_at_the_world_top_is_zero_test() {
  assert bounds.y_fraction_from_top(10.0, box) == 0.0
}

pub fn y_fraction_from_top_at_the_world_bottom_is_one_test() {
  assert bounds.y_fraction_from_top(0.0, box) == 1.0
}

pub fn y_fraction_from_top_at_the_midpoint_is_a_half_test() {
  assert bounds.y_fraction_from_top(5.0, box) == 0.5
}

pub fn y_fraction_from_top_is_linear_across_the_height_test() {
  assert bounds.y_fraction_from_top(9.0, box) == 0.1
  assert bounds.y_fraction_from_top(2.5, box) == 0.75
}

pub fn y_fraction_from_top_respects_a_non_zero_bounds_origin_test() {
  let offset_box = Bounds(min: Vector2(0.0, 100.0), max: Vector2(10.0, 200.0))
  assert bounds.y_fraction_from_top(200.0, offset_box) == 0.0
  assert bounds.y_fraction_from_top(100.0, offset_box) == 1.0
  assert bounds.y_fraction_from_top(150.0, offset_box) == 0.5
}

pub fn y_fraction_from_top_does_not_clamp_out_of_range_y_test() {
  assert bounds.y_fraction_from_top(15.0, box) == -0.5
  assert bounds.y_fraction_from_top(-5.0, box) == 1.5
}

pub fn clamp_x_inside_bounds_is_unchanged_test() {
  assert bounds.clamp_x(5.0, 1.0, box) == 5.0
}

pub fn clamp_x_on_the_effective_edge_is_unchanged_test() {
  assert bounds.clamp_x(1.0, 1.0, box) == 1.0
  assert bounds.clamp_x(9.0, 1.0, box) == 9.0
}

pub fn clamp_x_clamps_past_the_min_x_edge_test() {
  assert bounds.clamp_x(-5.0, 1.0, box) == 1.0
}

pub fn clamp_x_clamps_past_the_max_x_edge_test() {
  assert bounds.clamp_x(50.0, 1.0, box) == 9.0
}

pub fn clamp_x_larger_radius_clamps_sooner_test() {
  assert bounds.clamp_x(9.5, 1.0, box) == 9.0
  assert bounds.clamp_x(9.5, 0.1, box) == 9.5
}

pub fn clamp_x_degenerate_zero_size_bounds_resolves_toward_the_same_edge_bounce_would_test() {
  let point_box = Bounds(min: Vector2(5.0, 5.0), max: Vector2(5.0, 5.0))
  assert bounds.clamp_x(10.0, 1.0, point_box) == 4.0
}

pub fn x_fraction_at_the_left_edge_is_zero_test() {
  assert bounds.x_fraction(0.0, box) == 0.0
}

pub fn x_fraction_at_the_right_edge_is_one_test() {
  assert bounds.x_fraction(10.0, box) == 1.0
}

pub fn x_fraction_at_the_midpoint_is_a_half_test() {
  assert bounds.x_fraction(5.0, box) == 0.5
}

pub fn x_fraction_respects_a_non_zero_bounds_origin_test() {
  let offset_box = Bounds(min: Vector2(100.0, 0.0), max: Vector2(200.0, 10.0))
  assert bounds.x_fraction(100.0, offset_box) == 0.0
  assert bounds.x_fraction(200.0, offset_box) == 1.0
  assert bounds.x_fraction(150.0, offset_box) == 0.5
}

pub fn resolve_axis_passes_through_unchanged_inside_the_range_test() {
  assert bounds.resolve_axis(5.0, 3.0, 0.0, 10.0, float.negate, float.negate)
    == #(5.0, 3.0)
}

pub fn resolve_axis_applies_on_low_past_the_min_edge_test() {
  assert bounds.resolve_axis(-1.0, -3.0, 0.0, 10.0, float.negate, float.negate)
    == #(0.0, 3.0)
}

pub fn resolve_axis_applies_on_high_past_the_max_edge_test() {
  assert bounds.resolve_axis(11.0, 3.0, 0.0, 10.0, float.negate, float.negate)
    == #(10.0, -3.0)
}

pub fn resolve_axis_on_low_and_on_high_can_differ_test() {
  let stop = fn(_v) { 0.0 }
  assert bounds.resolve_axis(-1.0, -3.0, 0.0, 10.0, stop, float.negate)
    == #(0.0, 0.0)
  assert bounds.resolve_axis(11.0, 3.0, 0.0, 10.0, stop, float.negate)
    == #(10.0, -3.0)
}

pub fn resolve_high_only_passes_through_unchanged_inside_the_range_test() {
  assert bounds.resolve_high_only(5.0, 3.0, 10.0, float.negate) == #(5.0, 3.0)
}

pub fn resolve_high_only_applies_on_high_past_the_max_edge_test() {
  assert bounds.resolve_high_only(11.0, 3.0, 10.0, float.negate)
    == #(10.0, -3.0)
}

pub fn resolve_high_only_never_touches_a_position_below_max_test() {
  assert bounds.resolve_high_only(-1000.0, -3.0, 10.0, float.negate)
    == #(-1000.0, -3.0)
}
