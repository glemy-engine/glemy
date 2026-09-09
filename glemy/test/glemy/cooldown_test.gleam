import glemy/cooldown

pub fn tick_subtracts_dt_from_remaining_test() {
  assert cooldown.tick(0.5, 0.2) == 0.5 -. 0.2
}

pub fn tick_floors_at_zero_when_dt_exceeds_remaining_test() {
  assert cooldown.tick(0.1, 0.5) == 0.0
}

pub fn tick_lands_exactly_at_zero_when_dt_equals_remaining_test() {
  assert cooldown.tick(0.5, 0.5) == 0.0
}

pub fn tick_with_negative_dt_increases_remaining_test() {
  assert cooldown.tick(0.5, -0.2) == 0.7
}

pub fn is_ready_true_at_exactly_zero_test() {
  assert cooldown.is_ready(0.0)
}

pub fn is_ready_true_when_negative_test() {
  assert cooldown.is_ready(-1.0)
}

pub fn is_ready_false_when_positive_test() {
  assert !cooldown.is_ready(0.01)
}
