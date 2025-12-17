# Shade

Cross-platform shaders using the Haxe programming language.

Shade is a vertex and fragment shader transpiler that converts Haxe shader code to GLSL (OpenGL/WebGL) and Unity (HLSL/Cg) formats. It uses the [reflaxe](https://github.com/SomeRanDev/reflaxe) library for macro-based transpilation. Additional target shader languages can be added by providing custom backends.

This project is primarily intended to be used with [Ceramic](https://ceramic-engine.com), but could work with other game engines too. It is very close to the GLSL spec, although it doesn't try to cover the entirety of it.

## Table of Contents

- [Quick Start](#quick-start)
- [Command Line Interface](#command-line-interface)
- [Shader Structure](#shader-structure)
- [Field Annotations](#field-annotations)
- [Types](#types)
- [Built-in Functions](#built-in-functions)
- [Operators](#operators)
- [Control Flow](#control-flow)
- [Helper Functions](#helper-functions)
- [Multi-Texture Support](#multi-texture-support)
- [Output Examples](#output-examples)

## Quick Start

Here's a basic textured shader:

```haxe
package shaders;

class Textured extends Shader<Textured_Vert, Textured_Frag> {}

class Textured_Vert extends Vert {
    @param var projectionMatrix:Mat4;
    @param var modelViewMatrix:Mat4;

    @in var vertexPosition:Vec3;
    @in var vertexTCoord:Vec2;
    @in var vertexColor:Vec4;

    @out var tcoord:Vec2;
    @out var color:Vec4;

    function main():Vec4 {
        tcoord = vertexTCoord;
        color = vertexColor;
        return projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    }
}

class Textured_Frag extends Frag {
    @param var mainTex:Sampler2D;

    @in var tcoord:Vec2;
    @in var color:Vec4;

    function main():Vec4 {
        var texColor = texture(mainTex, tcoord);
        return color * texColor;
    }
}
```

### Setup

1. Install Haxe: https://haxe.org/download/

2. Install shade library:

```bash
# Install shade
haxelib install shade
```

3. Transpile your shader:

```bash
# Transpile to GLSL
haxelib run shade --in shaders/Textured.hx --target glsl --out output/

# Transpile to Unity (ShaderLab)
haxelib run shade --in shaders/Textured.hx --target unity --out output/
```

## Command Line Interface

Shade provides a CLI for transpiling shaders.

### Usage

```bash
haxelib run shade --in <shader.hx> --target <glsl|unity> [--out <dir>] [--hxml <extra>]
```

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--in <path>` | Yes | Input Haxe shader file (can be repeated for multiple files) |
| `--target <backend>` | Yes | Target backend: `glsl`, `unity`, or `custom` |
| `--out <dir>` | No | Output directory (default: current directory) |
| `--hxml <content>` | No | Additional hxml compiler options |

### Examples

```bash
# Single shader to GLSL
haxelib run shade --in src/Blur.hx --target glsl --out shaders/

# Multiple shaders to Unity
haxelib run shade --in src/Blur.hx --in src/Bloom.hx --target unity --out unity-shaders/

# With custom defines
haxelib run shade --in src/Custom.hx --target glsl --hxml "-D my_define"
```

## Shader Structure

Shaders are defined as Haxe classes:

- **`Shader<V, F>`** - Main shader class that pairs a vertex shader with a fragment shader
- **`Vert`** - Base class for vertex shaders (class name must end with `_Vert`)
- **`Frag`** - Base class for fragment shaders (class name must end with `_Frag`)

```haxe
class MyShader extends Shader<MyShader_Vert, MyShader_Frag> {}

class MyShader_Vert extends Vert {
    function main():Vec4 {
        // Return vertex position (becomes gl_Position)
        return vec4(0.0, 0.0, 0.0, 1.0);
    }
}

class MyShader_Frag extends Frag {
    function main():Vec4 {
        // Return fragment color (becomes fragColor)
        return vec4(1.0, 0.0, 0.0, 1.0);
    }
}
```

The `main()` function is required:
- In vertex shaders, it returns the vertex position (`Vec4`)
- In fragment shaders, it returns the fragment color (`Vec4`)

## Field Annotations

### `@param` - Uniform Parameters

Values passed from CPU to shader, constant for all vertices/fragments in a draw call:

```haxe
@param var projectionMatrix:Mat4;
@param var modelViewMatrix:Mat4;
@param var mainTex:Sampler2D;
@param var time:Float;
@param var resolution:Vec2;
```

### `@in` - Input Varyings

In **vertex shaders**: per-vertex attributes from vertex buffers:
```haxe
@in var vertexPosition:Vec3;
@in var vertexTCoord:Vec2;
@in var vertexColor:Vec4;
```

In **fragment shaders**: interpolated values from vertex shader outputs:
```haxe
@in var tcoord:Vec2;
@in var color:Vec4;
```

### `@out` - Output Varyings

Values computed in vertex shader, interpolated across the triangle, and read in the fragment shader:

```haxe
// In vertex shader
@out var tcoord:Vec2;
@out var color:Vec4;
```

The corresponding `@in` in the fragment shader must have the same name.

## Types

### Scalar Types

| Type | Description |
|------|-------------|
| `Float` | Single-precision floating point |
| `Int` | Integer |
| `Bool` | Boolean |

### Vector Types

| Type | Description |
|------|-------------|
| `Vec2` | 2-component float vector |
| `Vec3` | 3-component float vector |
| `Vec4` | 4-component float vector |

### Matrix Types

| Type | Description |
|------|-------------|
| `Mat2` | 2x2 float matrix (column-major) |
| `Mat3` | 3x3 float matrix (column-major) |
| `Mat4` | 4x4 float matrix (column-major) |

### Sampler Types

| Type | Description |
|------|-------------|
| `Sampler2D` | 2D texture sampler |

### Component Access

Vectors support multiple naming conventions for component access:

```haxe
var v:Vec4 = vec4(1.0, 2.0, 3.0, 4.0);

// Position components
v.x; v.y; v.z; v.w;

// Color components
v.r; v.g; v.b; v.a;

// Texture components
v.s; v.t; v.p; v.q;
```

### Swizzling

Read and write swizzles are supported:

```haxe
var pos:Vec3 = vec3(1.0, 2.0, 3.0);
var xy:Vec2 = pos.xy;               // Read swizzle: vec2(1.0, 2.0)
var rgb:Vec3 = vec4(1,2,3,4).rgb;   // Extract first 3 components

var color:Vec4 = vec4(0.0);
color.xyz = vec3(1.0, 0.0, 0.0);    // Write swizzle
```

## Built-in Functions

### Texture Sampling

| Function | Description |
|----------|-------------|
| `texture(sampler:Sampler2D, coord:Vec2):Vec4` | Sample texture at coordinate |

### Angle and Trigonometric Functions

| Function | Description |
|----------|-------------|
| `radians(degrees)` | Convert degrees to radians |
| `degrees(radians)` | Convert radians to degrees |
| `sin(angle)` | Sine (angle in radians) |
| `cos(angle)` | Cosine (angle in radians) |
| `tan(angle)` | Tangent (angle in radians) |
| `asin(x)` | Arc sine, returns [-π/2, π/2] |
| `acos(x)` | Arc cosine, returns [0, π] |
| `atan(y_over_x)` | Arc tangent, returns [-π/2, π/2] |
| `atan(y, x)` | Arc tangent of y/x using signs to determine quadrant, returns [-π, π] |

All trigonometric functions work on `Float`, `Vec2`, `Vec3`, and `Vec4`.

### Exponential Functions

| Function | Description |
|----------|-------------|
| `pow(x, y)` | x raised to power y |
| `exp(x)` | e^x |
| `exp2(x)` | 2^x |
| `log(x)` | Natural logarithm ln(x) |
| `log2(x)` | Base-2 logarithm |
| `sqrt(x)` | Square root |
| `inversesqrt(x)` | Inverse square root (1/√x) |

All exponential functions work on `Float`, `Vec2`, `Vec3`, and `Vec4`.

### Common Functions

| Function | Description |
|----------|-------------|
| `abs(x)` | Absolute value |
| `sign(x)` | Returns -1.0, 0.0, or 1.0 |
| `floor(x)` | Largest integer ≤ x |
| `ceil(x)` | Smallest integer ≥ x |
| `fract(x)` | Fractional part: x - floor(x) |
| `mod(x, y)` | Modulo: x - y * floor(x/y) |
| `min(x, y)` | Minimum value |
| `max(x, y)` | Maximum value |
| `clamp(x, min, max)` | Constrain x to [min, max] |
| `mix(x, y, a)` | Linear interpolation: x*(1-a) + y*a |
| `step(edge, x)` | 0.0 if x < edge, else 1.0 |
| `smoothstep(edge0, edge1, x)` | Smooth Hermite interpolation |

All common functions work on `Float`, `Vec2`, `Vec3`, and `Vec4`. Functions like `min`, `max`, `clamp`, and `mix` support both scalar and per-component operations.

### Geometric Functions

| Function | Description |
|----------|-------------|
| `length(x)` | Vector magnitude |
| `distance(p0, p1)` | Distance between points |
| `dot(x, y)` | Dot product |
| `cross(x, y)` | Cross product (Vec3 only) |
| `normalize(x)` | Unit vector in same direction |
| `faceforward(N, I, Nref)` | Orient normal toward viewer |
| `reflect(I, N)` | Reflection direction |
| `refract(I, N, eta)` | Refraction direction |

### Matrix Functions

| Function | Description |
|----------|-------------|
| `matrixCompMult(x, y)` | Component-wise multiplication (not matrix multiply) |
| `transpose(m)` | Matrix transpose |
| `determinant(m)` | Matrix determinant |
| `inverse(m)` | Matrix inverse (Mat2 only) |

### Fragment-Only Functions

These functions are only available in fragment shaders:

| Function | Description |
|----------|-------------|
| `dFdx(p)` | Partial derivative with respect to window x |
| `dFdy(p)` | Partial derivative with respect to window y |
| `fwidth(p)` | abs(dFdx(p)) + abs(dFdy(p)) |
| `discard()` | Discard current fragment |

### Constructor Functions

#### Vector Constructors

```haxe
// Vec2
vec2(x, y)          // From components
vec2(v)             // Broadcast scalar to all components
vec2(v)             // Take first 2 components

// Vec3
vec3(x, y, z)       // From components
vec3(v)             // Broadcast scalar
vec3(xy, z)         // From Vec2 + scalar
vec3(x, yz)         // From scalar + Vec2
vec3(v)             // Take first 3 components

// Vec4
vec4(x, y, z, w)    // From components
vec4(v)             // Broadcast scalar
vec4(xy, z, w)      // From Vec2 + scalars
vec4(xy, zw)        // From two Vec2
vec4(xyz, w)        // From Vec3 + scalar
vec4(x, yzw)        // From scalar + Vec3
```

#### Matrix Constructors

```haxe
// Mat2
mat2(v)                         // Diagonal matrix
mat2(col0, col1)                // From column vectors
mat2(m00, m10, m01, m11)        // From elements (column-major)

// Mat3
mat3(v)                         // Diagonal matrix
mat3(col0, col1, col2)          // From column vectors
mat3(m)                         // Extract upper-left 3x3

// Mat4
mat4(v)                         // Diagonal matrix
mat4(col0, col1, col2, col3)    // From column vectors
```

#### Type Conversion

```haxe
float(intValue)     // Convert integer to float
```

## Operators

### Arithmetic Operators

```haxe
a + b    // Addition
a - b    // Subtraction
a * b    // Multiplication (component-wise for vectors)
a / b    // Division
-a       // Negation
```

### Matrix-Vector Multiplication

```haxe
mat4 * vec4  // Transform vector by matrix
mat3 * vec3
mat2 * vec2
mat4 * mat4  // Matrix multiplication
```

### Comparison Operators

```haxe
a == b   // Equal
a != b   // Not equal
a < b    // Less than
a <= b   // Less than or equal
a > b    // Greater than
a >= b   // Greater than or equal
```

### Logical Operators

```haxe
a && b   // Logical AND
a || b   // Logical OR
!a       // Logical NOT
```

### Assignment Operators

```haxe
a = b    // Assignment
a += b   // Add and assign
a -= b   // Subtract and assign
a *= b   // Multiply and assign
a /= b   // Divide and assign
```

## Control Flow

### Local Variables

```haxe
var color:Vec4 = vec4(1.0, 0.0, 0.0, 1.0);
var intensity:Float = 0.5;
var count:Int = 0;
```

### Conditionals

```haxe
if (alpha < 0.5) {
    // discard transparent pixels
}

if (x > 0.0) {
    result = a;
} else {
    result = b;
}
```

### Loops

```haxe
var i:Int = 0;
while (i < 9) {
    sum += texture(mainTex, uv + offset * float(i));
    i++;
}
```

## Helper Functions

You can define helper functions within shader classes:

```haxe
class Msdf_Frag extends Frag {
    @param var mainTex:Sampler2D;
    @param var texSize:Vec2;
    @param var pxRange:Float;

    @in var tcoord:Vec2;
    @in var color:Vec4;

    // Helper function for MSDF text rendering
    function median(r:Float, g:Float, b:Float):Float {
        return max(min(r, g), min(max(r, g), b));
    }

    function main():Vec4 {
        var msdfUnit:Vec2 = vec2(pxRange) / texSize;
        var textureSample:Vec3 = texture(mainTex, tcoord).rgb;

        var sigDist:Float = median(textureSample.r, textureSample.g, textureSample.b) - 0.5;
        sigDist *= dot(msdfUnit, vec2(0.5) / fwidth(tcoord));

        var opacity:Float = clamp(sigDist + 0.5, 0.0, 1.0);
        var bgColor:Vec4 = vec4(0.0, 0.0, 0.0, 0.0);

        return mix(bgColor, color, opacity);
    }
}
```

## Multi-Texture Support

The `@multi` annotation enables dynamic multi-texture support, used by the [Ceramic](https://ceramic-engine.com) engine for sprite batching with multiple texture atlases.

When `@multi` is used, the compiler generates additional shader variants with branching code to select between multiple texture slots at runtime.

```haxe
class Textured_Vert extends Vert {
    @param var projectionMatrix:Mat4;
    @param var modelViewMatrix:Mat4;

    @in var vertexPosition:Vec3;
    @in var vertexTCoord:Vec2;
    @in var vertexColor:Vec4;
    @in @multi var vertexTextureId:Float;  // Texture slot index input

    @out var tcoord:Vec2;
    @out var color:Vec4;
    @out @multi var textureId:Float;       // Pass to fragment shader

    function main():Vec4 {
        tcoord = vertexTCoord;
        color = vertexColor;

        @multi textureId = vertexTextureId;  // Assignment in @multi context

        return projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    }
}

class Textured_Frag extends Frag {
    @param @multi var tex:Sampler2D;       // Multi-texture parameter

    @in var tcoord:Vec2;
    @in var color:Vec4;
    @in @multi var textureId:Float;        // Texture slot index

    function main():Vec4 {
        var texColor = vec4(0.0);

        @multi {                            // Generates branching for each texture slot
            texColor = texture(tex, tcoord);
        }

        return color * texColor;
    }
}
```

When compiled with `@multi`, additional `_mt8` shader variants are generated that support 8 texture slots through runtime branching.

## Output Examples

### GLSL Output

**Input (Haxe):**
```haxe
class Textured_Vert extends Vert {
    @param var projectionMatrix:Mat4;
    @param var modelViewMatrix:Mat4;

    @in var vertexPosition:Vec3;
    @in var vertexTCoord:Vec2;
    @in var vertexColor:Vec4;

    @out var tcoord:Vec2;
    @out var color:Vec4;

    function main():Vec4 {
        tcoord = vertexTCoord;
        color = vertexColor;
        return projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    }
}
```

**Output (GLSL vertex shader):**
```glsl
#version 300 es

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

in vec3 vertexPosition;
in vec2 vertexTCoord;
in vec4 vertexColor;

out vec2 tcoord;
out vec4 color;

void main(void) {
    tcoord = vertexTCoord;
    color = vertexColor;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    gl_PointSize = 1.0;
}
```

**Input (Haxe):**
```haxe
class Textured_Frag extends Frag {
    @param var mainTex:Sampler2D;

    @in var tcoord:Vec2;
    @in var color:Vec4;

    function main():Vec4 {
        var texColor = texture(mainTex, tcoord);
        return color * texColor;
    }
}
```

**Output (GLSL fragment shader):**
```glsl
#version 300 es

#ifdef GL_ES
precision mediump float;
#else
#define mediump
#endif

uniform sampler2D mainTex;

in vec2 tcoord;
in vec4 color;

out vec4 fragColor;

void main(void) {
    vec4 texColor = vec4(0.0);
    texColor = texture(mainTex, tcoord);
    fragColor = color * texColor;
}
```

### Unity Output

**Output (Unity ShaderLab):**
```hlsl
Shader "shaders_textured"
{
    Properties
    {
        [PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        _SrcBlendRgb ("Src Rgb", Float) = 0
        _DstBlendRgb ("Dst Rgb", Float) = 0
        _SrcBlendAlpha ("Src Alpha", Float) = 0
        _DstBlendAlpha ("Dst Alpha", Float) = 0
        _StencilComp ("Stencil Comp", Float) = 8
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend [_SrcBlendRgb] [_DstBlendRgb], [_SrcBlendAlpha] [_DstBlendAlpha]

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 shade_texture(sampler2D tex, float2 uv) {
                return tex2D(tex, float2(uv.x, 1.0 - uv.y));
            }

            struct appdata_t
            {
                float4 vertexPosition_ : POSITION;
                float2 vertexTCoord_ : TEXCOORD0;
                float4 vertexColor_ : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 tcoord_ : TEXCOORD0;
                float4 color_ : COLOR;
            };

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.position = UnityObjectToClipPos(IN.vertexPosition_.xyz);
                OUT.tcoord_ = IN.vertexTCoord_;
                OUT.color_ = IN.vertexColor_;
                return OUT;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f IN) : SV_Target
            {
                float4 texColor_ = float4(0.0, 0.0, 0.0, 0.0);
                texColor_ = shade_texture(_MainTex, IN.tcoord_);
                return IN.color_ * texColor_;
            }
        ENDCG
        }
    }
}
```

### Type Mappings

| Shade | GLSL | Unity HLSL |
|-------|------|------------|
| `Vec2` | `vec2` | `float2` |
| `Vec3` | `vec3` | `float3` |
| `Vec4` | `vec4` | `float4` |
| `Mat2` | `mat2` | `float2x2` |
| `Mat3` | `mat3` | `float3x3` |
| `Mat4` | `mat4` | `float4x4` |
| `Sampler2D` | `sampler2D` | `sampler2D` |

### Function Mappings

| Shade | GLSL | Unity HLSL |
|-------|------|------------|
| `texture()` | `texture()` | `shade_texture()` (with Y-flip) |
| `mix()` | `mix()` | `lerp()` |
| `fract()` | `fract()` | `frac()` |
| `mod()` | `mod()` | `shade_mod()` |
| `inversesqrt()` | `inversesqrt()` | `rsqrt()` |
| `dFdx()` | `dFdx()` | `ddx()` |
| `dFdy()` | `dFdy()` | `ddy()` |

## Requirements

The transpilation requires reflaxe. It is currently tested [on this commit](https://github.com/SomeRanDev/reflaxe/tree/5a91527c128d9ca7f34ae7a57b60da8746479663).

## Sample Shaders

The `test/` directory includes sample shaders copied from Ceramic:

- `Textured` - Basic textured rendering
- `Blur` - Box blur effect
- `Bloom` - Bloom/glow effect
- `GaussianBlur` - Gaussian blur
- `Glow` - Outer glow effect
- `InnerLight` - Inner lighting effect
- `Msdf` - Multi-channel signed distance field text
- `Outline` - Outline effect
- `PixelArt` - Pixel art post-processing
- `Fxaa` - Fast approximate anti-aliasing
- `TintBlack` - Tint with black level control
