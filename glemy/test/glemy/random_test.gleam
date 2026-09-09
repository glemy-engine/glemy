import glemy/random

pub fn pick_at_zero_picks_the_first_option_test() {
  assert random.pick(0.0, [0, 1, 2]) == Ok(0)
}

pub fn pick_near_one_picks_the_last_option_test() {
  assert random.pick(0.99, [0, 1, 2]) == Ok(2)
}

pub fn pick_in_the_middle_picks_the_middle_option_test() {
  assert random.pick(0.5, [0, 1, 2]) == Ok(1)
}

pub fn pick_covers_every_subset_boundary_test() {
  assert random.pick(0.32, [0, 1, 2]) == Ok(0)
  assert random.pick(0.34, [0, 1, 2]) == Ok(1)
  assert random.pick(0.65, [0, 1, 2]) == Ok(1)
  assert random.pick(0.67, [0, 1, 2]) == Ok(2)
}

pub fn pick_with_a_single_element_list_always_returns_it_test() {
  assert random.pick(0.0, [4]) == Ok(4)
  assert random.pick(0.5, [4]) == Ok(4)
  assert random.pick(0.99, [4]) == Ok(4)
}

pub fn pick_with_an_empty_list_is_an_error_test() {
  assert random.pick(0.5, []) == Error(Nil)
}

pub fn pick_clamps_out_of_range_random_values_test() {
  assert random.pick(-1.0, [0, 1, 2]) == Ok(0)
  assert random.pick(1.0, [0, 1, 2]) == Ok(2)
  assert random.pick(50.0, [0, 1, 2]) == Ok(2)
}

pub fn pick_works_over_any_type_not_just_int_test() {
  assert random.pick(0.5, ["red", "green", "blue"]) == Ok("green")
}
