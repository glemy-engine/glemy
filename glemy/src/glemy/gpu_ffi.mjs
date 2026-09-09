let devicePromise;

export function getDevice() {
  if (devicePromise === undefined) {
    devicePromise = (async () => {
      if (!globalThis.navigator?.gpu) {
        throw new Error(
          "navigator.gpu is not available. This project's JavaScript-target " +
            "tests require Deno with WebGPU enabled (gleam.toml sets " +
            "javascript.runtime = \"deno\", and deno.json sets " +
            "unstable: [\"webgpu\"]) -- Node is not supported. If you're seeing " +
            "this in a real browser, WebGPU itself isn't available there.",
        );
      }
      const adapter = await navigator.gpu.requestAdapter();
      if (!adapter) {
        throw new Error("no WebGPU adapter available");
      }
      return adapter.requestDevice();
    })();
  }
  return devicePromise;
}
