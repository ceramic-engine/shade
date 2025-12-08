package shade;

/**
 * Base class for fragment (pixel) shaders.
 * Extends Shade with fragment-specific functions like texture sampling and derivatives.
 */
extern class Frag extends Shade {

    /**
     * Samples a texture at the given coordinate.
     * @param sampler The texture sampler to read from
     * @param coord The texture coordinates (0.0 to 1.0 range typically)
     * @return The color value at the sampled location as a Vec4 (RGBA)
     */
    public function texture(sampler:Sampler2D, coord:Vec2):Vec4;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdx(p:Float):Float;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdx(p:Vec2):Vec2;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdx(p:Vec3):Vec3;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdx(p:Vec4):Vec4;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdy(p:Float):Float;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdy(p:Vec2):Vec2;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdy(p:Vec3):Vec3;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public overload function dFdy(p:Vec4):Vec4;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public overload function fwidth(p:Float):Float;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public overload function fwidth(p:Vec2):Vec2;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public overload function fwidth(p:Vec3):Vec3;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public overload function fwidth(p:Vec4):Vec4;

    /**
     * Discards the current fragment. The fragment will not be written to the framebuffer.
     * Only available in fragment shaders. Cannot be called conditionally in all implementations.
     */
    public function discard():Void;
}
