package shaders;

import shade.*;

// Shader ported from: https://github.com/kiwipxl/GLSL-shaders/blob/5bcd7ae0d86a04c31a7a081f0c379aa973d3813d/outline.glsl

class Outline extends Shader<Outline_Vert, Outline_Frag> {}

class Outline_Vert extends Vert {

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

class Outline_Frag extends Frag {

    @uniform var tex:Sampler2D;
    @uniform var resolution:Vec2;
    @uniform var outlineThickness:Float;
    @uniform var outlineColor:Vec3;
    @uniform var outlineThreshold:Float;

    @in var tcoord:Vec2;
    @in var color:Vec4;

    function main():Vec4 {

        var pixel:Vec4 = texture(tex, tcoord);
        var thickness:Float = outlineThickness * 0.25;

        if (pixel.a <= outlineThreshold) {

            var uvX:Float = tcoord.x;
            var uvY:Float = tcoord.y;

            var sum:Float = 0.0;
            var n:Int = 0;
            while (n < 9) {
                uvY = tcoord.y + (thickness * (float(n) - 4.0)) / resolution.y;
                var hSum:Float = 0.0;
                hSum += texture(tex, vec2(uvX - (4.0 * thickness) / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX - (3.0 * thickness) / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX - (2.0 * thickness) / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX - thickness / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX, uvY)).a;
                hSum += texture(tex, vec2(uvX + thickness / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX + (2.0 * thickness) / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX + (3.0 * thickness) / resolution.x, uvY)).a;
                hSum += texture(tex, vec2(uvX + (4.0 * thickness) / resolution.x, uvY)).a;
                sum += hSum / 9.0;
                n++;
            }

            if (sum / 9.0 >= 0.0001) {
                pixel = vec4(outlineColor, 1.0);
            }
        }

        return color * pixel;

    }

}
