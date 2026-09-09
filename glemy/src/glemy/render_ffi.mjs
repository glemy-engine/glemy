import { getDevice } from "./gpu_ffi.mjs";
import { Ok, Error as GleamError, toList } from "../gleam.mjs";

const WIDTH = 64;
const HEIGHT = 64;
const BYTES_PER_PIXEL = 4;
const BYTES_PER_ROW = WIDTH * BYTES_PER_PIXEL; 
const TEXTURE_FORMAT = "rgba8unorm";

const SHADER_SOURCE = `
@group(0) @binding(0) var<uniform> center: vec2<f32>;
@group(0) @binding(1) var<uniform> radius: f32;
@group(0) @binding(2) var<uniform> bounds_min: vec2<f32>;
@group(0) @binding(3) var<uniform> bounds_max: vec2<f32>;
@group(0) @binding(4) var<uniform> color: vec4<f32>;

struct VertexOutput {
  @builtin(position) clip_position: vec4<f32>,
  @location(0) local_uv: vec2<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOutput {
  var corners = array<vec2<f32>, 4>(
    vec2<f32>(-1.0, -1.0),
    vec2<f32>(1.0, -1.0),
    vec2<f32>(-1.0, 1.0),
    vec2<f32>(1.0, 1.0),
  );
  let corner = corners[vertex_index];

  let world_pos = center + corner * radius;
  let extent = bounds_max - bounds_min;
  let ndc = (world_pos - bounds_min) / extent * 2.0 - vec2<f32>(1.0, 1.0);

  var out: VertexOutput;
  out.clip_position = vec4<f32>(ndc, 0.0, 1.0);
  out.local_uv = corner;
  return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  if length(in.local_uv) > 1.0 {
    discard;
  }
  return color;
}
`;

let cachedPipeline;

function getPipeline(device) {
  if (cachedPipeline !== undefined) {
    return cachedPipeline;
  }
  const shaderModule = device.createShaderModule({ code: SHADER_SOURCE });
  const bindGroupLayout = device.createBindGroupLayout({
    entries: [
      {
        binding: 0,
        visibility: GPUShaderStage.VERTEX,
        buffer: { type: "uniform" },
      },
      {
        binding: 1,
        visibility: GPUShaderStage.VERTEX,
        buffer: { type: "uniform" },
      },
      {
        binding: 2,
        visibility: GPUShaderStage.VERTEX,
        buffer: { type: "uniform" },
      },
      {
        binding: 3,
        visibility: GPUShaderStage.VERTEX,
        buffer: { type: "uniform" },
      },
      {
        binding: 4,
        visibility: GPUShaderStage.FRAGMENT,
        buffer: { type: "uniform" },
      },
    ],
  });
  const pipeline = device.createRenderPipeline({
    layout: device.createPipelineLayout({
      bindGroupLayouts: [bindGroupLayout],
    }),
    vertex: { module: shaderModule, entryPoint: "vs_main" },
    fragment: {
      module: shaderModule,
      entryPoint: "fs_main",
      targets: [{ format: TEXTURE_FORMAT }],
    },
    primitive: { topology: "triangle-strip" },
  });
  cachedPipeline = { pipeline, bindGroupLayout };
  return cachedPipeline;
}

function makeUniformBuffer(device, floats) {
  const buffer = device.createBuffer({
    size: floats.length * Float32Array.BYTES_PER_ELEMENT,
    usage: GPUBufferUsage.UNIFORM,
    mappedAtCreation: true,
  });
  new Float32Array(buffer.getMappedRange()).set(floats);
  buffer.unmap();
  return buffer;
}

function drawEntities(pass, device, bindGroupLayout, entities, bounds) {
  const boundsMinBuffer = makeUniformBuffer(device, [
    bounds.min.x,
    bounds.min.y,
  ]);
  const boundsMaxBuffer = makeUniformBuffer(device, [
    bounds.max.x,
    bounds.max.y,
  ]);

  entities.forEach(([e, [r, g, b]]) => {
    const centerBuffer = makeUniformBuffer(device, [e.position.x, e.position.y]);
    const radiusBuffer = makeUniformBuffer(device, [e.radius]);
    const colorBuffer = makeUniformBuffer(device, [r, g, b, 1.0]);
    const bindGroup = device.createBindGroup({
      layout: bindGroupLayout,
      entries: [
        { binding: 0, resource: { buffer: centerBuffer } },
        { binding: 1, resource: { buffer: radiusBuffer } },
        { binding: 2, resource: { buffer: boundsMinBuffer } },
        { binding: 3, resource: { buffer: boundsMaxBuffer } },
        { binding: 4, resource: { buffer: colorBuffer } },
      ],
    });
    pass.setBindGroup(0, bindGroup);
    pass.draw(4);
  });
}

export function getCanvasElement(id) {
  return document.getElementById(id);
}

export async function renderEntitiesToBytes(entitiesList, bounds) {
  try {
    const entities = entitiesList.toArray();

    const device = await getDevice();
    const { pipeline, bindGroupLayout } = getPipeline(device);

    const texture = device.createTexture({
      size: [WIDTH, HEIGHT],
      format: TEXTURE_FORMAT,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
    });

    const encoder = device.createCommandEncoder();
    const pass = encoder.beginRenderPass({
      colorAttachments: [
        {
          view: texture.createView(),
          clearValue: { r: 0, g: 0, b: 0, a: 1 },
          loadOp: "clear",
          storeOp: "store",
        },
      ],
    });
    pass.setPipeline(pipeline);
    drawEntities(pass, device, bindGroupLayout, entities, bounds);
    pass.end();

    const readBuffer = device.createBuffer({
      size: BYTES_PER_ROW * HEIGHT,
      usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST,
    });
    encoder.copyTextureToBuffer(
      { texture },
      { buffer: readBuffer, bytesPerRow: BYTES_PER_ROW },
      [WIDTH, HEIGHT],
    );
    device.queue.submit([encoder.finish()]);
    await device.queue.onSubmittedWorkDone();

    await readBuffer.mapAsync(GPUMapMode.READ);
    const bytes = new Uint8Array(readBuffer.getMappedRange().slice(0));
    readBuffer.unmap();

    return new Ok(toList(Array.from(bytes)));
  } catch (error) {
    return new GleamError(
      error instanceof Error ? error.message : String(error),
    );
  }
}

function paddedBytesPerRow(width) {
  const unpadded = width * BYTES_PER_PIXEL;
  const align = 256;
  return Math.ceil(unpadded / align) * align;
}

export async function renderEntitiesToCanvasRaw(entitiesList, bounds, canvas) {
  try {
    const entities = entitiesList.toArray();
    const width = canvas.width;
    const height = canvas.height;

    const device = await getDevice();
    const { pipeline, bindGroupLayout } = getPipeline(device);

    const context = canvas.getContext("webgpu");
    if (context === null) {
      return new GleamError("canvas has no webgpu context");
    }
    context.configure({
      device,
      format: TEXTURE_FORMAT,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
    });
    const texture = context.getCurrentTexture();

    const encoder = device.createCommandEncoder();
    const pass = encoder.beginRenderPass({
      colorAttachments: [
        {
          view: texture.createView(),
          clearValue: { r: 0, g: 0, b: 0, a: 1 },
          loadOp: "clear",
          storeOp: "store",
        },
      ],
    });
    pass.setPipeline(pipeline);
    drawEntities(pass, device, bindGroupLayout, entities, bounds);
    pass.end();

    const bytesPerRow = paddedBytesPerRow(width);
    const readBuffer = device.createBuffer({
      size: bytesPerRow * height,
      usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST,
    });
    encoder.copyTextureToBuffer(
      { texture },
      { buffer: readBuffer, bytesPerRow },
      [width, height],
    );
    device.queue.submit([encoder.finish()]);
    await device.queue.onSubmittedWorkDone();

    await readBuffer.mapAsync(GPUMapMode.READ);
    const padded = new Uint8Array(readBuffer.getMappedRange().slice(0));
    readBuffer.unmap();

    return new Ok([width, height, bytesPerRow, toList(Array.from(padded))]);
  } catch (error) {
    return new GleamError(
      error instanceof Error ? error.message : String(error),
    );
  }
}
