import glemy/physics/vector2.{type Vector2}

@target(javascript)
@external(javascript, "./io_ffi.mjs", "isKeyDown")
pub fn is_key_down(key: String) -> Bool

@target(javascript)
@external(javascript, "./io_ffi.mjs", "mousePosition")
pub fn mouse_position() -> Vector2

@target(javascript)
@external(javascript, "./io_ffi.mjs", "isMouseButtonDown")
pub fn is_mouse_button_down(button: Int) -> Bool
