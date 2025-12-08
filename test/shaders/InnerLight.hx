package shaders;

import shade.*;

class InnerLight extends Shader<InnerLight_Vert, InnerLight_Frag> {}

class InnerLight_Vert extends Vert {

    @uniform var projectionMatrix:Mat4;
    @uniform var modelViewMatrix:Mat4;

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

class InnerLight_Frag extends Frag {

    @uniform var tex:Sampler2D;
    @uniform var gap:Vec2;
    @uniform var lightColor:Vec4;

    @in var tcoord:Vec2;
    @in var color:Vec4;

    function main():Vec4 {

        var pixel:Vec4 = texture(tex, tcoord);
        var outsidePixel:Vec4 = texture(tex, vec2(tcoord.x + gap.x, tcoord.y + gap.y));

        pixel *= color;

        var lightAlpha:Float = (1.0 - outsidePixel.a) * lightColor.a * pixel.a;

        return vec4(
            min(1.0, pixel.r + lightColor.r * lightAlpha),
            min(1.0, pixel.g + lightColor.g * lightAlpha),
            min(1.0, pixel.b + lightColor.b * lightAlpha),
            pixel.a
        );

    }

}
