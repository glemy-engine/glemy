import glemy/physics/vector2.{Vector2}

pub fn add_test() {
  assert vector2.add(Vector2(1.0, 2.0), Vector2(3.0, 4.0)) == Vector2(4.0, 6.0)
}

pub fn add_with_negative_components_test() {
  assert vector2.add(Vector2(-1.0, -2.0), Vector2(3.0, -4.0))
    == Vector2(2.0, -6.0)
}

pub fn add_zero_is_identity_test() {
  let v = Vector2(7.5, -3.25)
  assert vector2.add(v, vector2.zero) == v
  assert vector2.add(vector2.zero, v) == v
}

pub fn add_is_commutative_test() {
  let a = Vector2(1.0, -2.0)
  let b = Vector2(-3.5, 4.5)
  assert vector2.add(a, b) == vector2.add(b, a)
}

pub fn subtract_test() {
  assert vector2.subtract(Vector2(3.0, 4.0), Vector2(1.0, 2.0))
    == Vector2(2.0, 2.0)
}

pub fn subtract_from_itself_is_zero_test() {
  let v = Vector2(9.0, -4.0)
  assert vector2.subtract(v, v) == vector2.zero
}

pub fn subtract_zero_is_identity_test() {
  let v = Vector2(7.5, -3.25)
  assert vector2.subtract(v, vector2.zero) == v
}

pub fn add_and_subtract_are_inverses_test() {
  let a = Vector2(2.0, 3.0)
  let b = Vector2(-5.0, 10.0)
  assert vector2.subtract(vector2.add(a, b), b) == a
}

pub fn scale_test() {
  assert vector2.scale(Vector2(1.0, 2.0), 2.0) == Vector2(2.0, 4.0)
}

pub fn scale_by_zero_gives_zero_vector_test() {
  assert vector2.loosely_equals(
    vector2.scale(Vector2(123.0, -456.0), 0.0),
    vector2.zero,
    0.0001,
  )
}

pub fn scale_by_zero_with_only_positive_components_is_exactly_zero_test() {
  assert vector2.scale(Vector2(123.0, 456.0), 0.0) == vector2.zero
}

pub fn scale_by_one_is_identity_test() {
  let v = Vector2(7.5, -3.25)
  assert vector2.scale(v, 1.0) == v
}

pub fn scale_by_negative_one_negates_test() {
  assert vector2.scale(Vector2(3.0, -4.0), -1.0) == Vector2(-3.0, 4.0)
}

pub fn scale_by_negative_number_test() {
  assert vector2.scale(Vector2(2.0, -3.0), -2.0) == Vector2(-4.0, 6.0)
}

pub fn scale_zero_vector_is_still_zero_test() {
  assert vector2.scale(vector2.zero, 999.0) == vector2.zero
}

pub fn dot_test() {
  assert vector2.dot(Vector2(-6.0, 8.0), Vector2(5.0, 12.0)) == 66.0
}

pub fn dot_with_zero_vector_is_zero_test() {
  assert vector2.dot(Vector2(3.0, 4.0), vector2.zero) == 0.0
}

pub fn dot_of_perpendicular_vectors_is_zero_test() {
  assert vector2.dot(Vector2(1.0, 0.0), Vector2(0.0, 1.0)) == 0.0
}

pub fn dot_is_commutative_test() {
  let a = Vector2(2.0, -3.0)
  let b = Vector2(-5.0, 7.0)
  assert vector2.dot(a, b) == vector2.dot(b, a)
}

pub fn dot_of_a_vector_with_itself_is_length_squared_test() {
  let v = Vector2(3.0, 4.0)
  assert vector2.dot(v, v) == vector2.length_squared(v)
}

pub fn length_squared_test() {
  assert vector2.length_squared(Vector2(3.0, 4.0)) == 25.0
}

pub fn length_squared_of_zero_vector_is_zero_test() {
  assert vector2.length_squared(vector2.zero) == 0.0
}

pub fn length_squared_with_negative_components_test() {
  assert vector2.length_squared(Vector2(-3.0, -4.0)) == 25.0
}

pub fn length_test() {
  assert vector2.length(Vector2(3.0, 4.0)) == 5.0
}

pub fn length_of_zero_vector_is_zero_test() {
  assert vector2.length(vector2.zero) == 0.0
}

pub fn length_with_negative_components_test() {
  assert vector2.length(Vector2(-3.0, -4.0)) == 5.0
}

pub fn length_of_axis_aligned_vector_test() {
  assert vector2.length(Vector2(5.0, 0.0)) == 5.0
  assert vector2.length(Vector2(0.0, -5.0)) == 5.0
}

pub fn zero_test() {
  assert vector2.zero == Vector2(0.0, 0.0)
}

pub fn loosely_equals_identical_vectors_test() {
  let v = Vector2(1.0, 2.0)
  assert vector2.loosely_equals(v, v, 0.0)
}

pub fn loosely_equals_within_tolerance_test() {
  assert vector2.loosely_equals(
    Vector2(1.0, 2.0),
    Vector2(1.0000001, 2.0),
    0.001,
  )
}

pub fn loosely_equals_clearly_outside_tolerance_on_x_test() {
  assert !vector2.loosely_equals(Vector2(1.0, 2.0), Vector2(1.5, 2.0), 0.001)
}

pub fn loosely_equals_clearly_outside_tolerance_on_y_test() {
  assert !vector2.loosely_equals(Vector2(1.0, 2.0), Vector2(1.0, 2.5), 0.001)
}

pub fn loosely_equals_with_zero_tolerance_requires_exact_match_test() {
  assert !vector2.loosely_equals(
    Vector2(1.0, 2.0),
    Vector2(1.0000001, 2.0),
    0.0,
  )
}

pub fn loosely_equals_is_symmetric_test() {
  let a = Vector2(1.0, 2.0)
  let b = Vector2(1.05, 2.05)
  assert vector2.loosely_equals(a, b, 0.1) == vector2.loosely_equals(b, a, 0.1)
}
