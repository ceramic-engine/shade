package shade;

#if (!macro && shade_for_haxe)
#if shade_base_sampler2d
typedef Sampler2D = shade.BaseSampler2D;
#else
abstract Sampler2D(Any) {}
#end
#else
extern class Sampler2D {}
#end
