import { Vector2 } from "./physics/vector2.mjs";

export const eventTarget = globalThis.window ?? new EventTarget();

let pressedKeys = new Set();
let mouseButtonsDown = new Set();
let mouseX = 0;
let mouseY = 0;

eventTarget.addEventListener("keydown", (e) => pressedKeys.add(e.key));
eventTarget.addEventListener("keyup", (e) => pressedKeys.delete(e.key));
eventTarget.addEventListener("mousemove", (e) => {
  mouseX = e.clientX;
  mouseY = e.clientY;
});
eventTarget.addEventListener("mousedown", (e) =>
  mouseButtonsDown.add(e.button),
);
eventTarget.addEventListener("mouseup", (e) =>
  mouseButtonsDown.delete(e.button),
);

export function isKeyDown(key) {
  return pressedKeys.has(key);
}

export function mousePosition() {
  return new Vector2(mouseX, mouseY);
}

export function isMouseButtonDown(button) {
  return mouseButtonsDown.has(button);
}
