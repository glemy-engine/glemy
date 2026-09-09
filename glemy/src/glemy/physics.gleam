import gleam/list
import glemy/physics/bounds.{type Bounds}
import glemy/physics/collision_sweep.{type PairInteraction}
import glemy/physics/entity.{type Entity}
import glemy/physics/vector2.{type Vector2}

pub type Model {
  Model(entities: List(Entity), bounds: Bounds, gravity: Vector2)
}

pub const max_dt = 0.03333333333333333

pub fn update(
  model: Model,
  dt: Float,
  wall_behavior: fn(Entity, Bounds) -> Entity,
  interact: fn(Entity, Entity) -> PairInteraction(event),
) -> #(Model, List(event)) {
  let moved =
    list.map(model.entities, fn(e) {
      entity.integrate(e, model.gravity, dt)
      |> wall_behavior(model.bounds)
    })
  let #(resolved_entities, events) =
    collision_sweep.resolve_all_collisions(moved, interact)
  #(Model(..model, entities: resolved_entities), events)
}

pub fn spawn_entity(model: Model, entity: Entity) -> Model {
  Model(..model, entities: [entity, ..model.entities])
}

pub fn entity_count(model: Model) -> Int {
  list.length(model.entities)
}

pub fn settle_all(model: Model, dt: Float) -> Model {
  Model(
    ..model,
    entities: list.map(model.entities, fn(e) { entity.settle(e, dt) }),
  )
}
