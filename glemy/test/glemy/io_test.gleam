import glemy/io
import glemy/physics/vector2.{Vector2}

@target(javascript)
@external(javascript, "./io_test_ffi.mjs", "dispatchKeyDown")
fn dispatch_key_down(key: String) -> Nil

@target(javascript)
@external(javascript, "./io_test_ffi.mjs", "dispatchKeyUp")
fn dispatch_key_up(key: String) -> Nil

@target(javascript)
@external(javascript, "./io_test_ffi.mjs", "dispatchMouseMove")
fn dispatch_mouse_move(x: Float, y: Float) -> Nil

@target(javascript)
@external(javascript, "./io_test_ffi.mjs", "dispatchMouseDown")
fn dispatch_mouse_down(button: Int) -> Nil

@target(javascript)
@external(javascript, "./io_test_ffi.mjs", "dispatchMouseUp")
fn dispatch_mouse_up(button: Int) -> Nil

@target(javascript)
pub fn is_key_down_reflects_real_keydown_and_keyup_events_test() {
  assert io.is_key_down("a") == False

  dispatch_key_down("a")
  assert io.is_key_down("a") == True
  assert io.is_key_down("b") == False

  dispatch_key_up("a")
  assert io.is_key_down("a") == False
}

@target(javascript)
pub fn multiple_keys_can_be_down_simultaneously_test() {
  dispatch_key_down("a")
  dispatch_key_down("b")
  assert io.is_key_down("a") == True
  assert io.is_key_down("b") == True
  assert io.is_key_down("c") == False

  dispatch_key_up("a")
  assert io.is_key_down("a") == False
  assert io.is_key_down("b") == True

  dispatch_key_up("b")
}

@target(javascript)
pub fn a_second_keydown_without_an_intervening_keyup_is_idempotent_test() {
  dispatch_key_down("a")
  dispatch_key_down("a")
  assert io.is_key_down("a") == True

  dispatch_key_up("a")
  assert io.is_key_down("a") == False
}

@target(javascript)
pub fn multiple_mouse_buttons_can_be_down_simultaneously_test() {
  dispatch_mouse_down(0)
  dispatch_mouse_down(2)
  assert io.is_mouse_button_down(0) == True
  assert io.is_mouse_button_down(2) == True
  assert io.is_mouse_button_down(1) == False

  dispatch_mouse_up(0)
  assert io.is_mouse_button_down(0) == False
  assert io.is_mouse_button_down(2) == True

  dispatch_mouse_up(2)
}

@target(javascript)
pub fn mouse_position_reflects_real_mousemove_events_test() {
  dispatch_mouse_move(12.0, 34.0)

  assert io.mouse_position() == Vector2(12.0, 34.0)
}

@target(javascript)
pub fn is_mouse_button_down_reflects_real_mouse_events_test() {
  assert io.is_mouse_button_down(0) == False

  dispatch_mouse_down(0)
  assert io.is_mouse_button_down(0) == True
  assert io.is_mouse_button_down(2) == False

  dispatch_mouse_up(0)
  assert io.is_mouse_button_down(0) == False
}
