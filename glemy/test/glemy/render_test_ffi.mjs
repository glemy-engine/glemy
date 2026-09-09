export function createOffscreenCanvas(width, height) {
  return new OffscreenCanvas(width, height);
}

export function createCanvasWithNoWebgpuContext(width, height) {
  const canvas = new OffscreenCanvas(width, height);
  canvas.getContext("bitmaprenderer");
  return canvas;
}
