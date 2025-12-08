package shaders;

import shade.*;

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
