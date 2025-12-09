# Shade

Cross-platform shaders using the Haxe programming language.

```haxe
class Textured extends Shader<Textured_Vert, Textured_Frag> {}

class Textured_Vert extends Vert {

    @uniform var projectionMatrix:Mat4;
    @uniform var modelViewMatrix:Mat4;

    @in var vertexPosition:Vec3;
    @in var vertexTCoord:Vec2;
    @in var vertexColor:Vec4;
    @in @multi var vertexTextureId:Float;

    @out var tcoord:Vec2;
    @out var color:Vec4;
    @out @multi var textureId:Float;

    function main():Vec4 {
        tcoord = vertexTCoord;
        color = vertexColor;

        @multi textureId = vertexTextureId;

        return projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
    }
}

class Textured_Frag extends Frag {

    @uniform @multi var tex:Sampler2D;

    @in var tcoord:Vec2;
    @in var color:Vec4;
    @in @multi var textureId:Float;

    function main():Vec4 {
        var texColor = vec4(0.0);

        @multi {
            texColor = texture(tex, tcoord);
        }

        return color * texColor;
    }
}
```

This project is primarily intended to be used with [Ceramic](https://ceramic-engine.com), but could work with other game engines too. It is very close to the GLSL spec, although it doesn't try to cover the entirety of it.

`test/` directory includes sample shaders which are just copied from Ceramic.

The transpilation needs reflaxe. It is currently tested [on this commit](https://github.com/SomeRanDev/reflaxe/tree/5a91527c128d9ca7f34ae7a57b60da8746479663).

⚠ Under active development, not advised to rely on it yet!
