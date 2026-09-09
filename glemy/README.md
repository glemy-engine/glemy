# glemy

A small 2D circle-physics/game engine for [Gleam](https://gleam.run),
targeting both the Erlang and JavaScript runtimes. Follows a
[Functional Core, Imperative Shell](https://kennethlange.com/functional-core-imperative-shell/)
split.

## Installation

Add `glemy` to your Gleam project.

```sh
gleam add glemy
```

## Usage

```gleam
import glemy/physics
import glemy/physics/bounds.{Bounds}
import glemy/physics/collision_sweep.{Bounce}
import glemy/physics/entity.{Entity}
import glemy/physics/vector2.{Vector2}

pub fn main() {
  let bounds = Bounds(min: Vector2(0.0, 0.0), max: Vector2(100.0, 100.0))

  let model =
    physics.Model(entities: [], bounds: bounds, gravity: Vector2(0.0, -9.8))
    |> physics.spawn_entity(Entity(
      position: Vector2(50.0, 90.0),
      velocity: vector2.zero,
      radius: 5.0,
      kind: 0,
      resting_time: 0.0,
    ))

  // Advance one frame: integrate under gravity, bounce off `bounds`,
  // and resolve any overlaps as plain elastic bounces (`Bounce`) --
  // pass your own function instead of `fn(_a, _b) { Bounce }` to merge,
  // destroy, or otherwise react to a specific pair of entities.
  let #(next_model, _events) =
    physics.update(model, 1.0 /. 60.0, bounds.bounce, fn(_a, _b) { Bounce })

  physics.entity_count(next_model)
}
```
