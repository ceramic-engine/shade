package shade;

/**
 * Base class for vertex shaders.
 * Provides vertex-specific functions in addition to common functions from Shade.
 */
extern class Vert extends Shade {
    // Most shader functions are shared between vertex and fragment shaders,
    // so they are defined in the parent Shade class.
    //
    // Vertex-specific built-in variables and outputs are handled
    // by the rendering backend during shader compilation.
}
