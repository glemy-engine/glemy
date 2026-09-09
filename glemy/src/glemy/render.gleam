import gleam/javascript/promise.{type Promise}
import gleam/list
import glemy/physics/bounds.{type Bounds}
import glemy/physics/entity.{type Entity}

pub type Canvas

@target(javascript)
@external(javascript, "./render_ffi.mjs", "getCanvasElement")
pub fn get_canvas(id: String) -> Canvas

pub const texture_width = 64

pub const texture_height = 64

pub type ColoredEntity =
  #(Entity, #(Float, Float, Float))

@target(javascript)
pub fn render_entities_to_bytes(
  entities: List(ColoredEntity),
  bounds: Bounds,
) -> Promise(Result(List(Int), String)) {
  render_entities_to_bytes_raw(entities, bounds)
}

@target(javascript)
@external(javascript, "./render_ffi.mjs", "renderEntitiesToBytes")
fn render_entities_to_bytes_raw(
  entities: List(ColoredEntity),
  bounds: Bounds,
) -> Promise(Result(List(Int), String))

@target(javascript)
@external(javascript, "./render_ffi.mjs", "renderEntitiesToCanvasRaw")
fn render_entities_to_canvas_raw(
  entities: List(ColoredEntity),
  bounds: Bounds,
  canvas: Canvas,
) -> Promise(Result(#(Int, Int, Int, List(Int)), String))

@target(javascript)
pub fn render_entities_to_canvas(
  entities: List(ColoredEntity),
  bounds: Bounds,
  canvas: Canvas,
) -> Promise(Result(List(Int), String)) {
  render_entities_to_canvas_raw(entities, bounds, canvas)
  |> promise.map(fn(result) {
    case result {
      Ok(#(width, height, bytes_per_row, padded)) ->
        Ok(strip_row_padding(padded, width, height, bytes_per_row))
      Error(message) -> Error(message)
    }
  })
}

fn strip_row_padding(
  padded: List(Int),
  width: Int,
  height: Int,
  bytes_per_row: Int,
) -> List(Int) {
  let row_bytes = width * 4
  case bytes_per_row == row_bytes {
    True -> padded
    False -> strip_rows(padded, row_bytes, bytes_per_row, height)
  }
}

fn strip_rows(
  padded: List(Int),
  row_bytes: Int,
  bytes_per_row: Int,
  remaining_rows: Int,
) -> List(Int) {
  case remaining_rows {
    0 -> []
    _ ->
      list.append(
        list.take(padded, row_bytes),
        strip_rows(
          list.drop(padded, bytes_per_row),
          row_bytes,
          bytes_per_row,
          remaining_rows - 1,
        ),
      )
  }
}
