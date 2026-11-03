package shaders;

/**
 * Constructs the Unity backend got wrong (checked in its output,
 * out-unity/shaders_unityChecks.shader): vertex locals used by @out
 * assignments, a fragment helper reading @in fields, and the argument
 * order of `atan(y, x)` (HLSL `atan2(y, x)`).
 */
class UnityChecks extends Shader<UnityChecks_Vert, UnityChecks_Frag> {}

class UnityChecks_Vert extends Vert {

    @param var projectionMatrix:Mat4;
    @param var modelViewMatrix:Mat4;

    @in var vertexPosition:Vec3;
    @in var vertexTCoord:Vec2;
    @in var vertexColor:Vec4;

    @out var tcoord:Vec2;
    @out var color:Vec4;

    function main():Vec4 {

        var scaled:Vec2 = vertexTCoord * 2.0;
        tcoord = scaled - vec2(1.0);
        color = vertexColor;

        return projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);

    }

}

class UnityChecks_Frag extends Frag {

    @in var tcoord:Vec2;
    @in var color:Vec4;

    function angle():Float {
        return atan(tcoord.y, tcoord.x);
    }

    function main():Vec4 {

        return color * (angle() / 6.2831853 + 0.5);

    }

}
