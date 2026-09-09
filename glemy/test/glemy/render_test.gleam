import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/list
import glemy/physics/bounds.{Bounds}
import glemy/physics/entity.{Entity}
import glemy/physics/vector2.{Vector2}
import glemy/render.{type Canvas}

const bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(100.0, 100.0))

const red = #(1.0, 0.0, 0.0)

const green = #(0.0, 1.0, 0.0)

@target(javascript)
@external(javascript, "./render_test_ffi.mjs", "createOffscreenCanvas")
fn create_offscreen_canvas(width: Int, height: Int) -> Canvas

@target(javascript)
@external(javascript, "./render_test_ffi.mjs", "createCanvasWithNoWebgpuContext")
fn create_canvas_with_no_webgpu_context(width: Int, height: Int) -> Canvas

@target(javascript)
pub fn render_entities_to_bytes_draws_circles_test() -> Promise(Nil) {
  let center_entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: vector2.zero,
      radius: 40.0,
    )
  let corner_entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5.0, 5.0),
      velocity: vector2.zero,
      radius: 3.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(center_entity, red), #(corner_entity, red)],
    bounds,
  ))
  let assert Ok(bytes) = result
  assert list.length(bytes) == render.texture_width * render.texture_height * 4

  assert pixel_at(bytes, 32, 32) == Red

  let corners = [
    pixel_at(bytes, 3, 3),
    pixel_at(bytes, 60, 3),
    pixel_at(bytes, 3, 60),
    pixel_at(bytes, 60, 60),
  ]
  assert list.filter(corners, fn(p) { p == Red }) |> list.length == 1
  assert list.filter(corners, fn(p) { p == Background }) |> list.length == 3
}

@target(javascript)
pub fn render_entities_to_bytes_gives_each_entity_its_own_paired_color_test() -> Promise(
  Nil,
) {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(25.0, 50.0),
      velocity: vector2.zero,
      radius: 15.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(75.0, 50.0),
      velocity: vector2.zero,
      radius: 15.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(a, red), #(b, green)],
    bounds,
  ))
  let assert Ok(bytes) = result

  assert pixel_at(bytes, 16, 32) == Red
  assert pixel_at(bytes, 48, 32) == Green
}

@target(javascript)
pub fn render_entities_to_bytes_with_no_entities_is_just_background_test() -> Promise(
  Nil,
) {
  use result <- promise.map(render.render_entities_to_bytes([], bounds))
  let assert Ok(bytes) = result
  assert pixel_at(bytes, 32, 32) == Background
}

@target(javascript)
pub fn render_entities_to_bytes_with_zero_radius_draws_nothing_test() -> Promise(
  Nil,
) {
  let invisible =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: vector2.zero,
      radius: 0.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(invisible, red)],
    bounds,
  ))
  let assert Ok(bytes) = result
  assert list.length(bytes) == render.texture_width * render.texture_height * 4
  assert list.all(bytes_to_pixels(bytes), fn(p) { p == Background })
}

@target(javascript)
pub fn render_entities_to_bytes_entirely_outside_bounds_is_clipped_not_crashed_test() -> Promise(
  Nil,
) {
  let offscreen =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(5000.0, 5000.0),
      velocity: vector2.zero,
      radius: 10.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(offscreen, red)],
    bounds,
  ))
  let assert Ok(bytes) = result
  assert list.all(bytes_to_pixels(bytes), fn(p) { p == Background })
}

@target(javascript)
pub fn render_entities_to_bytes_overlapping_entities_still_draw_solid_test() -> Promise(
  Nil,
) {
  let a =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: vector2.zero,
      radius: 30.0,
    )
  let b =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(55.0, 50.0),
      velocity: vector2.zero,
      radius: 30.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(a, red), #(b, red)],
    bounds,
  ))
  let assert Ok(bytes) = result
  assert pixel_at(bytes, 32, 32) == Red
}

@target(javascript)
pub fn render_entities_to_bytes_stretches_circles_into_ellipses_on_non_square_bounds_test() -> Promise(
  Nil,
) {
  let wide_bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(200.0, 100.0))
  let entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(100.0, 50.0),
      velocity: vector2.zero,
      radius: 40.0,
    )

  use result <- promise.map(render.render_entities_to_bytes(
    [#(entity, red)],
    wide_bounds,
  ))
  let assert Ok(bytes) = result

  assert pixel_at(bytes, 52, 32) == Background
  assert pixel_at(bytes, 12, 32) == Background
  assert pixel_at(bytes, 32, 52) == Red
  assert pixel_at(bytes, 32, 12) == Red
}

@target(javascript)
pub fn render_entities_to_bytes_draws_many_entities_without_crashing_test() -> Promise(
  Nil,
) {
  let colored_entities =
    list.repeat(Nil, 10)
    |> list.index_map(fn(_, i) {
      let offset = int.to_float(i) *. 10.0
      #(
        Entity(
          resting_time: 0.0,
          kind: 0,
          position: Vector2(5.0 +. offset, 50.0),
          velocity: vector2.zero,
          radius: 2.0,
        ),
        red,
      )
    })

  use result <- promise.map(render.render_entities_to_bytes(
    colored_entities,
    bounds,
  ))
  let assert Ok(bytes) = result
  assert list.length(bytes) == render.texture_width * render.texture_height * 4
  assert list.any(bytes_to_pixels(bytes), fn(p) { p == Red })
}

@target(javascript)
pub fn render_entities_to_canvas_draws_circles_test() -> Promise(Nil) {
  let center_entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(50.0, 50.0),
      velocity: vector2.zero,
      radius: 40.0,
    )
  let canvas = create_offscreen_canvas(64, 64)

  use result <- promise.map(render.render_entities_to_canvas(
    [#(center_entity, red)],
    bounds,
    canvas,
  ))
  let assert Ok(bytes) = result
  assert list.length(bytes) == 64 * 64 * 4
  assert pixel_at(bytes, 32, 32) == Red
}

@target(javascript)
pub fn render_entities_to_canvas_with_no_entities_is_just_background_test() -> Promise(
  Nil,
) {
  let canvas = create_offscreen_canvas(64, 64)

  use result <- promise.map(render.render_entities_to_canvas([], bounds, canvas))
  let assert Ok(bytes) = result
  assert list.all(bytes_to_pixels(bytes), fn(p) { p == Background })
}

@target(javascript)
pub fn render_entities_to_canvas_handles_unaligned_row_widths_test() -> Promise(
  Nil,
) {
  let odd_width_canvas = create_offscreen_canvas(50, 30)
  let small_bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(50.0, 30.0))
  let entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(25.0, 15.0),
      velocity: vector2.zero,
      radius: 40.0,
    )

  use result <- promise.map(render.render_entities_to_canvas(
    [#(entity, red)],
    small_bounds,
    odd_width_canvas,
  ))
  let assert Ok(bytes) = result
  assert list.length(bytes) == 50 * 30 * 4
  let offset = { 29 * 50 + 25 } * 4
  let assert [r, g, b, _a] = bytes |> list.drop(offset) |> list.take(4)
  assert #(r, g, b) == #(255, 0, 0)
}

@target(javascript)
pub fn render_entities_to_canvas_handles_a_single_pixel_canvas_test() -> Promise(
  Nil,
) {
  let tiny_canvas = create_offscreen_canvas(1, 1)
  let tiny_bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(1.0, 1.0))
  let entity =
    Entity(
      resting_time: 0.0,
      kind: 0,
      position: Vector2(0.5, 0.5),
      velocity: vector2.zero,
      radius: 10.0,
    )

  use result <- promise.map(render.render_entities_to_canvas(
    [#(entity, red)],
    tiny_bounds,
    tiny_canvas,
  ))
  let assert Ok(bytes) = result
  assert bytes == [255, 0, 0, 255]
}

@target(javascript)
pub fn render_entities_to_bytes_and_render_entities_to_canvas_agree_test() -> Promise(
  Nil,
) {
  let colored_entities = [
    #(
      Entity(
        resting_time: 0.0,
        kind: 0,
        position: Vector2(30.0, 30.0),
        velocity: vector2.zero,
        radius: 15.0,
      ),
      red,
    ),
    #(
      Entity(
        resting_time: 0.0,
        kind: 0,
        position: Vector2(70.0, 70.0),
        velocity: vector2.zero,
        radius: 10.0,
      ),
      green,
    ),
  ]
  let canvas = create_offscreen_canvas(64, 64)

  use bytes_result <- promise.await(render.render_entities_to_bytes(
    colored_entities,
    bounds,
  ))
  use canvas_result <- promise.map(render.render_entities_to_canvas(
    colored_entities,
    bounds,
    canvas,
  ))
  let assert Ok(bytes) = bytes_result
  let assert Ok(canvas_bytes) = canvas_result
  assert bytes == canvas_bytes
}

@target(javascript)
pub fn render_entities_to_canvas_without_a_webgpu_context_is_an_error_test() -> Promise(
  Nil,
) {
  let canvas = create_canvas_with_no_webgpu_context(64, 64)

  use result <- promise.map(render.render_entities_to_canvas([], bounds, canvas))
  assert result == Error("canvas has no webgpu context")
}

type Pixel {
  Red
  Green
  Background
  Other
}

fn pixel_at(bytes: List(Int), x: Int, y: Int) -> Pixel {
  let offset = { y * render.texture_width + x } * 4
  let assert [r, g, b, _a] = bytes |> list.drop(offset) |> list.take(4)
  case r, g, b {
    255, 0, 0 -> Red
    0, 255, 0 -> Green
    0, 0, 0 -> Background
    _, _, _ -> Other
  }
}

fn bytes_to_pixels(bytes: List(Int)) -> List(Pixel) {
  case bytes {
    [r, g, b, _a, ..rest] -> {
      let pixel = case r, g, b {
        255, 0, 0 -> Red
        0, 0, 0 -> Background
        _, _, _ -> Other
      }
      [pixel, ..bytes_to_pixels(rest)]
    }
    _ -> []
  }
}
