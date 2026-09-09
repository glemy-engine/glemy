import glemy/stopwatch

pub fn tick_accumulates_dt_while_holding_test() {
  assert stopwatch.tick(1.0, 0.5, True) == 1.0 +. 0.5
}

pub fn tick_starts_accumulating_from_zero_test() {
  assert stopwatch.tick(0.0, 0.3, True) == 0.3
}

pub fn tick_resets_to_zero_when_not_holding_test() {
  assert stopwatch.tick(5.0, 0.5, False) == 0.0
}

pub fn tick_resets_to_zero_from_zero_test() {
  assert stopwatch.tick(0.0, 0.5, False) == 0.0
}

pub fn tick_with_negative_dt_while_holding_decreases_elapsed_test() {
  assert stopwatch.tick(1.0, -0.4, True) == 0.6
}
