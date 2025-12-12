package shade;

/**
 * Base class for fragment (pixel) shaders.
 */
#if (!macro && shade_for_haxe)
@:autoBuild(shade.macros.ShadeMacro.buildFragVertForHaxe())
#end
abstract class Frag extends Shade {

    //

}
