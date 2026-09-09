import { eventTarget } from "./io_ffi.mjs";

function dispatch(type, properties) {
  const event = new Event(type);
  Object.assign(event, properties);
  eventTarget.dispatchEvent(event);
}

export function dispatchKeyDown(key) {
  dispatch("keydown", { key });
}

export function dispatchKeyUp(key) {
  dispatch("keyup", { key });
}

export function dispatchMouseMove(x, y) {
  dispatch("mousemove", { clientX: x, clientY: y });
}

export function dispatchMouseDown(button) {
  dispatch("mousedown", { button });
}

export function dispatchMouseUp(button) {
  dispatch("mouseup", { button });
}
