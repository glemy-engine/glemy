import glemy/physics/collision
import glemy/physics/entity.{type Entity}

pub type PairInteraction(event) {
  Bounce
  Consume(replacement: Entity, event: event)
}

type ResolveOutcome(event) {
  Survived(final_target: Entity, resolved_rest: List(Entity))
  Consumed(replacement: Entity, remaining_rest: List(Entity), event: event)
}

pub fn resolve_all_collisions(
  entities: List(Entity),
  interact: fn(Entity, Entity) -> PairInteraction(event),
) -> #(List(Entity), List(event)) {
  case entities {
    [] -> #([], [])
    [first, ..rest] -> {
      case resolve_target_against_rest(first, rest, interact) {
        Consumed(replacement, remaining, event) -> {
          let #(further, more_events) =
            resolve_all_collisions(remaining, interact)
          #([replacement, ..further], [event, ..more_events])
        }
        Survived(final_target, resolved_rest) -> {
          let #(further, more_events) =
            resolve_all_collisions(resolved_rest, interact)
          #([final_target, ..further], more_events)
        }
      }
    }
  }
}

fn resolve_target_against_rest(
  target: Entity,
  rest: List(Entity),
  interact: fn(Entity, Entity) -> PairInteraction(event),
) -> ResolveOutcome(event) {
  case rest {
    [] -> Survived(target, [])
    [next, ..remaining] -> {
      case interact(target, next) {
        Consume(replacement, event) -> Consumed(replacement, remaining, event)
        Bounce -> {
          let #(resolved_target, resolved_next) =
            collision.resolve(target, next)
          case
            resolve_target_against_rest(resolved_target, remaining, interact)
          {
            Survived(final_target, resolved_remaining) ->
              Survived(final_target, [resolved_next, ..resolved_remaining])
            Consumed(replacement, remaining_rest, event) ->
              Consumed(replacement, [resolved_next, ..remaining_rest], event)
          }
        }
      }
    }
  }
}
