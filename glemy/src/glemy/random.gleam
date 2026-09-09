import gleam/float
import gleam/int
import gleam/list

pub fn pick(random: Float, options: List(a)) -> Result(a, Nil) {
  case options {
    [] -> Error(Nil)
    _ -> {
      let count = list.length(options)
      let index =
        float.truncate(random *. int.to_float(count))
        |> int.clamp(0, count - 1)
      case list.drop(options, index) {
        [option, ..] -> Ok(option)
        [] -> Error(Nil)
      }
    }
  }
}
