package shade;

#if shade_for_haxe
@:genericBuild(shade.macros.ShadeMacro.buildShaderForHaxe())
#end
class Shader<V:Vert=Vert,F:Frag=Frag> #if shade_base_shader extends shade.BaseShader #end {
    public var vert:V;
    public var frag:F;
}
