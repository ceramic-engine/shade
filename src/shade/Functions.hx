package shade;

extern class Functions {

    // ============================================================
    // Fragment-specific helpers
    // ============================================================

    /**
     * Samples a texture at the given coordinate.
     * @param sampler The texture sampler to read from
     * @param coord The texture coordinates (0.0 to 1.0 range typically)
     * @return The color value at the sampled location as a Vec4 (RGBA)
     */
    public static function texture(sampler:Sampler2D, coord:Vec2):Vec4;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdx(p:Float):Float;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdx(p:Vec2):Vec2;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdx(p:Vec3):Vec3;

    /**
     * Returns the partial derivative of p with respect to the window x coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdx(p:Vec4):Vec4;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdy(p:Float):Float;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdy(p:Vec2):Vec2;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdy(p:Vec3):Vec3;

    /**
     * Returns the partial derivative of p with respect to the window y coordinate.
     * Only available in fragment shaders. Useful for computing rates of change for anti-aliasing.
     */
    public static overload function dFdy(p:Vec4):Vec4;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public static overload function fwidth(p:Float):Float;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public static overload function fwidth(p:Vec2):Vec2;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public static overload function fwidth(p:Vec3):Vec3;

    /**
     * Returns the sum of the absolute values of derivatives in x and y.
     * Equivalent to abs(dFdx(p)) + abs(dFdy(p)).
     * Useful for determining how fast a value is changing for anti-aliasing purposes.
     */
    public static overload function fwidth(p:Vec4):Vec4;

    /**
     * Discards the current fragment. The fragment will not be written to the framebuffer.
     * Only available in fragment shaders. Cannot be called conditionally in all implementations.
     */
    public static function discard():Void;

    // ============================================================
    // Float helpers
    // ============================================================

    /** Get a float value from an int. */
    public static overload function float(x:Int):Float;

    // ============================================================
    // Vector Constructor Functions
    // ============================================================

    /** Constructs a 2-component vector from individual x and y values. */
    public static overload function vec2(x:Float, y:Float):Vec2;

    /** Constructs a 2-component vector with both components set to the same value. */
    public static overload function vec2(v:Float):Vec2;

    /** Constructs a 2-component vector by copying another Vec2. */
    public static overload function vec2(v:Vec2):Vec2;

    /** Constructs a 2-component vector from the first two components of a Vec3. */
    public static overload function vec2(v:Vec3):Vec2;

    /** Constructs a 2-component vector from the first two components of a Vec4. */
    public static overload function vec2(v:Vec4):Vec2;

    /** Constructs a 3-component vector from individual x, y, and z values. */
    public static overload function vec3(x:Float, y:Float, z:Float):Vec3;

    /** Constructs a 3-component vector with all components set to the same value. */
    public static overload function vec3(v:Float):Vec3;

    /** Constructs a 3-component vector by copying another Vec3. */
    public static overload function vec3(v:Vec3):Vec3;

    /** Constructs a 3-component vector from a Vec2 (xy) and a float (z). */
    public static overload function vec3(xy:Vec2, z:Float):Vec3;

    /** Constructs a 3-component vector from a float (x) and a Vec2 (yz). */
    public static overload function vec3(x:Float, yz:Vec2):Vec3;

    /** Constructs a 3-component vector from the first three components of a Vec4. */
    public static overload function vec3(v:Vec4):Vec3;

    /** Constructs a 4-component vector from individual x, y, z, and w values. */
    public static overload function vec4(x:Float, y:Float, z:Float, w:Float):Vec4;

    /** Constructs a 4-component vector with all components set to the same value. */
    public static overload function vec4(v:Float):Vec4;

    /** Constructs a 4-component vector by copying another Vec4. */
    public static overload function vec4(v:Vec4):Vec4;

    /** Constructs a 4-component vector from a Vec2 (xy) and two floats (z, w). */
    public static overload function vec4(xy:Vec2, z:Float, w:Float):Vec4;

    /** Constructs a 4-component vector from two floats (x, y) and a Vec2 (zw). */
    public static overload function vec4(x:Float, y:Float, zw:Vec2):Vec4;

    /** Constructs a 4-component vector from two Vec2 values (xy and zw). */
    public static overload function vec4(xy:Vec2, zw:Vec2):Vec4;

    /** Constructs a 4-component vector from a Vec3 (xyz) and a float (w). */
    public static overload function vec4(xyz:Vec3, w:Float):Vec4;

    /** Constructs a 4-component vector from a float (x) and a Vec3 (yzw). */
    public static overload function vec4(x:Float, yzw:Vec3):Vec4;

    // ============================================================
    // Matrix Constructor Functions
    // ============================================================

    /** Constructs a 2x2 diagonal matrix with the specified value on the diagonal. */
    public static overload function mat2(v:Float):Mat2;

    /** Constructs a 2x2 matrix from two column vectors. */
    public static overload function mat2(col0:Vec2, col1:Vec2):Mat2;

    /** Constructs a 2x2 matrix from individual components in column-major order. */
    public static overload function mat2(m00:Float, m10:Float, m01:Float, m11:Float):Mat2;

    /** Constructs a 3x3 diagonal matrix with the specified value on the diagonal. */
    public static overload function mat3(v:Float):Mat3;

    /** Constructs a 3x3 matrix from three column vectors. */
    public static overload function mat3(col0:Vec3, col1:Vec3, col2:Vec3):Mat3;

    /** Constructs a 3x3 matrix from the upper-left 3x3 portion of a Mat4. */
    public static overload function mat3(m:Mat4):Mat3;

    /** Constructs a 4x4 diagonal matrix with the specified value on the diagonal. */
    public static overload function mat4(v:Float):Mat4;

    /** Constructs a 4x4 matrix from four column vectors. */
    public static overload function mat4(col0:Vec4, col1:Vec4, col2:Vec4, col3:Vec4):Mat4;

    // ============================================================
    // Angle and Trigonometric Functions
    // ============================================================

    /** Converts degrees to radians. Returns (π/180) * degrees. */
    public static overload function radians(degrees:Float):Float;

    /** Converts degrees to radians for each component. Returns (π/180) * degrees. */
    public static overload function radians(degrees:Vec2):Vec2;

    /** Converts degrees to radians for each component. Returns (π/180) * degrees. */
    public static overload function radians(degrees:Vec3):Vec3;

    /** Converts degrees to radians for each component. Returns (π/180) * degrees. */
    public static overload function radians(degrees:Vec4):Vec4;

    /** Converts radians to degrees. Returns (180/π) * radians. */
    public static overload function degrees(radians:Float):Float;

    /** Converts radians to degrees for each component. Returns (180/π) * radians. */
    public static overload function degrees(radians:Vec2):Vec2;

    /** Converts radians to degrees for each component. Returns (180/π) * radians. */
    public static overload function degrees(radians:Vec3):Vec3;

    /** Converts radians to degrees for each component. Returns (180/π) * radians. */
    public static overload function degrees(radians:Vec4):Vec4;

    /** Returns the sine of the angle (in radians). */
    public static overload function sin(angle:Float):Float;

    /** Returns the sine of each component of the angle vector (in radians). */
    public static overload function sin(angle:Vec2):Vec2;

    /** Returns the sine of each component of the angle vector (in radians). */
    public static overload function sin(angle:Vec3):Vec3;

    /** Returns the sine of each component of the angle vector (in radians). */
    public static overload function sin(angle:Vec4):Vec4;

    /** Returns the cosine of the angle (in radians). */
    public static overload function cos(angle:Float):Float;

    /** Returns the cosine of each component of the angle vector (in radians). */
    public static overload function cos(angle:Vec2):Vec2;

    /** Returns the cosine of each component of the angle vector (in radians). */
    public static overload function cos(angle:Vec3):Vec3;

    /** Returns the cosine of each component of the angle vector (in radians). */
    public static overload function cos(angle:Vec4):Vec4;

    /** Returns the tangent of the angle (in radians). */
    public static overload function tan(angle:Float):Float;

    /** Returns the tangent of each component of the angle vector (in radians). */
    public static overload function tan(angle:Vec2):Vec2;

    /** Returns the tangent of each component of the angle vector (in radians). */
    public static overload function tan(angle:Vec3):Vec3;

    /** Returns the tangent of each component of the angle vector (in radians). */
    public static overload function tan(angle:Vec4):Vec4;

    /** Returns the arc sine (inverse sine) of x. The result is in radians, in the range [-π/2, π/2]. */
    public static overload function asin(x:Float):Float;

    /** Returns the arc sine of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function asin(x:Vec2):Vec2;

    /** Returns the arc sine of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function asin(x:Vec3):Vec3;

    /** Returns the arc sine of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function asin(x:Vec4):Vec4;

    /** Returns the arc cosine (inverse cosine) of x. The result is in radians, in the range [0, π]. */
    public static overload function acos(x:Float):Float;

    /** Returns the arc cosine of each component. Results are in radians, in the range [0, π]. */
    public static overload function acos(x:Vec2):Vec2;

    /** Returns the arc cosine of each component. Results are in radians, in the range [0, π]. */
    public static overload function acos(x:Vec3):Vec3;

    /** Returns the arc cosine of each component. Results are in radians, in the range [0, π]. */
    public static overload function acos(x:Vec4):Vec4;

    /** Returns the arc tangent of y/x. The result is in radians, in the range [-π/2, π/2]. */
    public static overload function atan(yOverX:Float):Float;

    /** Returns the arc tangent of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function atan(yOverX:Vec2):Vec2;

    /** Returns the arc tangent of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function atan(yOverX:Vec3):Vec3;

    /** Returns the arc tangent of each component. Results are in radians, in the range [-π/2, π/2]. */
    public static overload function atan(yOverX:Vec4):Vec4;

    /** Returns the arc tangent of y/x using the signs of both arguments to determine the quadrant. The result is in radians, in the range [-π, π]. */
    public static overload function atan(y:Float, x:Float):Float;

    /** Returns the arc tangent of y/x component-wise, using signs to determine the quadrant. Results are in radians, in the range [-π, π]. */
    public static overload function atan(y:Vec2, x:Vec2):Vec2;

    /** Returns the arc tangent of y/x component-wise, using signs to determine the quadrant. Results are in radians, in the range [-π, π]. */
    public static overload function atan(y:Vec3, x:Vec3):Vec3;

    /** Returns the arc tangent of y/x component-wise, using signs to determine the quadrant. Results are in radians, in the range [-π, π]. */
    public static overload function atan(y:Vec4, x:Vec4):Vec4;

    // ============================================================
    // Exponential Functions
    // ============================================================

    /** Returns x raised to the power y (x^y). */
    public static overload function pow(x:Float, y:Float):Float;

    /** Returns x raised to the power y component-wise (x^y). */
    public static overload function pow(x:Vec2, y:Vec2):Vec2;

    /** Returns x raised to the power y component-wise (x^y). */
    public static overload function pow(x:Vec3, y:Vec3):Vec3;

    /** Returns x raised to the power y component-wise (x^y). */
    public static overload function pow(x:Vec4, y:Vec4):Vec4;

    /** Returns the natural exponentiation of x (e^x). */
    public static overload function exp(x:Float):Float;

    /** Returns the natural exponentiation of each component (e^x). */
    public static overload function exp(x:Vec2):Vec2;

    /** Returns the natural exponentiation of each component (e^x). */
    public static overload function exp(x:Vec3):Vec3;

    /** Returns the natural exponentiation of each component (e^x). */
    public static overload function exp(x:Vec4):Vec4;

    /** Returns the natural logarithm of x (ln(x)). Results are undefined if x <= 0. */
    public static overload function log(x:Float):Float;

    /** Returns the natural logarithm of each component (ln(x)). Results are undefined if x <= 0. */
    public static overload function log(x:Vec2):Vec2;

    /** Returns the natural logarithm of each component (ln(x)). Results are undefined if x <= 0. */
    public static overload function log(x:Vec3):Vec3;

    /** Returns the natural logarithm of each component (ln(x)). Results are undefined if x <= 0. */
    public static overload function log(x:Vec4):Vec4;

    /** Returns 2 raised to the power x (2^x). */
    public static overload function exp2(x:Float):Float;

    /** Returns 2 raised to the power of each component (2^x). */
    public static overload function exp2(x:Vec2):Vec2;

    /** Returns 2 raised to the power of each component (2^x). */
    public static overload function exp2(x:Vec3):Vec3;

    /** Returns 2 raised to the power of each component (2^x). */
    public static overload function exp2(x:Vec4):Vec4;

    /** Returns the base-2 logarithm of x (log₂(x)). Results are undefined if x <= 0. */
    public static overload function log2(x:Float):Float;

    /** Returns the base-2 logarithm of each component (log₂(x)). Results are undefined if x <= 0. */
    public static overload function log2(x:Vec2):Vec2;

    /** Returns the base-2 logarithm of each component (log₂(x)). Results are undefined if x <= 0. */
    public static overload function log2(x:Vec3):Vec3;

    /** Returns the base-2 logarithm of each component (log₂(x)). Results are undefined if x <= 0. */
    public static overload function log2(x:Vec4):Vec4;

    /** Returns the square root of x. Results are undefined if x < 0. */
    public static overload function sqrt(x:Float):Float;

    /** Returns the square root of each component. Results are undefined if x < 0. */
    public static overload function sqrt(x:Vec2):Vec2;

    /** Returns the square root of each component. Results are undefined if x < 0. */
    public static overload function sqrt(x:Vec3):Vec3;

    /** Returns the square root of each component. Results are undefined if x < 0. */
    public static overload function sqrt(x:Vec4):Vec4;

    /** Returns the inverse square root of x (1/√x). Results are undefined if x <= 0. */
    public static overload function inversesqrt(x:Float):Float;

    /** Returns the inverse square root of each component (1/√x). Results are undefined if x <= 0. */
    public static overload function inversesqrt(x:Vec2):Vec2;

    /** Returns the inverse square root of each component (1/√x). Results are undefined if x <= 0. */
    public static overload function inversesqrt(x:Vec3):Vec3;

    /** Returns the inverse square root of each component (1/√x). Results are undefined if x <= 0. */
    public static overload function inversesqrt(x:Vec4):Vec4;

    // ============================================================
    // Common Functions
    // ============================================================

    /** Returns the absolute value of x. */
    public static overload function abs(x:Float):Float;

    /** Returns the absolute value of each component. */
    public static overload function abs(x:Vec2):Vec2;

    /** Returns the absolute value of each component. */
    public static overload function abs(x:Vec3):Vec3;

    /** Returns the absolute value of each component. */
    public static overload function abs(x:Vec4):Vec4;

    /** Returns -1.0, 0.0, or 1.0 depending on the sign of x. Returns -1.0 if x < 0, 0.0 if x == 0, and 1.0 if x > 0. */
    public static overload function sign(x:Float):Float;

    /** Returns the sign of each component: -1.0, 0.0, or 1.0. */
    public static overload function sign(x:Vec2):Vec2;

    /** Returns the sign of each component: -1.0, 0.0, or 1.0. */
    public static overload function sign(x:Vec3):Vec3;

    /** Returns the sign of each component: -1.0, 0.0, or 1.0. */
    public static overload function sign(x:Vec4):Vec4;

    /** Returns the largest integer value less than or equal to x. */
    public static overload function floor(x:Float):Float;

    /** Returns the largest integer value less than or equal to each component. */
    public static overload function floor(x:Vec2):Vec2;

    /** Returns the largest integer value less than or equal to each component. */
    public static overload function floor(x:Vec3):Vec3;

    /** Returns the largest integer value less than or equal to each component. */
    public static overload function floor(x:Vec4):Vec4;

    /** Returns the smallest integer value greater than or equal to x. */
    public static overload function ceil(x:Float):Float;

    /** Returns the smallest integer value greater than or equal to each component. */
    public static overload function ceil(x:Vec2):Vec2;

    /** Returns the smallest integer value greater than or equal to each component. */
    public static overload function ceil(x:Vec3):Vec3;

    /** Returns the smallest integer value greater than or equal to each component. */
    public static overload function ceil(x:Vec4):Vec4;

    /** Returns the fractional part of x: x - floor(x). */
    public static overload function fract(x:Float):Float;

    /** Returns the fractional part of each component: x - floor(x). */
    public static overload function fract(x:Vec2):Vec2;

    /** Returns the fractional part of each component: x - floor(x). */
    public static overload function fract(x:Vec3):Vec3;

    /** Returns the fractional part of each component: x - floor(x). */
    public static overload function fract(x:Vec4):Vec4;

    /** Returns the modulus of x and y: x - y * floor(x/y). */
    public static overload function mod(x:Float, y:Float):Float;

    /** Returns the modulus of each component of x with y: x - y * floor(x/y). */
    public static overload function mod(x:Vec2, y:Float):Vec2;

    /** Returns the modulus of x and y component-wise: x - y * floor(x/y). */
    public static overload function mod(x:Vec2, y:Vec2):Vec2;

    /** Returns the modulus of each component of x with y: x - y * floor(x/y). */
    public static overload function mod(x:Vec3, y:Float):Vec3;

    /** Returns the modulus of x and y component-wise: x - y * floor(x/y). */
    public static overload function mod(x:Vec3, y:Vec3):Vec3;

    /** Returns the modulus of each component of x with y: x - y * floor(x/y). */
    public static overload function mod(x:Vec4, y:Float):Vec4;

    /** Returns the modulus of x and y component-wise: x - y * floor(x/y). */
    public static overload function mod(x:Vec4, y:Vec4):Vec4;

    /** Returns the smaller of x and y. */
    public static overload function min(x:Float, y:Float):Float;

    /** Returns the smaller of x and y for each component. */
    public static overload function min(x:Vec2, y:Vec2):Vec2;

    /** Returns the smaller of each component of x and the scalar y. */
    public static overload function min(x:Vec2, y:Float):Vec2;

    /** Returns the smaller of x and y for each component. */
    public static overload function min(x:Vec3, y:Vec3):Vec3;

    /** Returns the smaller of each component of x and the scalar y. */
    public static overload function min(x:Vec3, y:Float):Vec3;

    /** Returns the smaller of x and y for each component. */
    public static overload function min(x:Vec4, y:Vec4):Vec4;

    /** Returns the smaller of each component of x and the scalar y. */
    public static overload function min(x:Vec4, y:Float):Vec4;

    /** Returns the larger of x and y. */
    public static overload function max(x:Float, y:Float):Float;

    /** Returns the larger of x and y for each component. */
    public static overload function max(x:Vec2, y:Vec2):Vec2;

    /** Returns the larger of each component of x and the scalar y. */
    public static overload function max(x:Vec2, y:Float):Vec2;

    /** Returns the larger of x and y for each component. */
    public static overload function max(x:Vec3, y:Vec3):Vec3;

    /** Returns the larger of each component of x and the scalar y. */
    public static overload function max(x:Vec3, y:Float):Vec3;

    /** Returns the larger of x and y for each component. */
    public static overload function max(x:Vec4, y:Vec4):Vec4;

    /** Returns the larger of each component of x and the scalar y. */
    public static overload function max(x:Vec4, y:Float):Vec4;

    /** Constrains x to the range [minVal, maxVal]. Returns min(max(x, minVal), maxVal). */
    public static overload function clamp(x:Float, minVal:Float, maxVal:Float):Float;

    /** Constrains each component of x to the range [minVal, maxVal]. */
    public static overload function clamp(x:Vec2, minVal:Float, maxVal:Float):Vec2;

    /** Constrains each component of x to the corresponding range [minVal, maxVal]. */
    public static overload function clamp(x:Vec2, minVal:Vec2, maxVal:Vec2):Vec2;

    /** Constrains each component of x to the range [minVal, maxVal]. */
    public static overload function clamp(x:Vec3, minVal:Float, maxVal:Float):Vec3;

    /** Constrains each component of x to the corresponding range [minVal, maxVal]. */
    public static overload function clamp(x:Vec3, minVal:Vec3, maxVal:Vec3):Vec3;

    /** Constrains each component of x to the range [minVal, maxVal]. */
    public static overload function clamp(x:Vec4, minVal:Float, maxVal:Float):Vec4;

    /** Constrains each component of x to the corresponding range [minVal, maxVal]. */
    public static overload function clamp(x:Vec4, minVal:Vec4, maxVal:Vec4):Vec4;

    /** Performs linear interpolation between x and y using a. Returns x*(1-a) + y*a. */
    public static overload function mix(x:Float, y:Float, a:Float):Float;

    /** Performs linear interpolation between x and y using a. Returns x*(1-a) + y*a component-wise. */
    public static overload function mix(x:Vec2, y:Vec2, a:Float):Vec2;

    /** Performs linear interpolation between x and y using a for each component. */
    public static overload function mix(x:Vec2, y:Vec2, a:Vec2):Vec2;

    /** Performs linear interpolation between x and y using a. Returns x*(1-a) + y*a component-wise. */
    public static overload function mix(x:Vec3, y:Vec3, a:Float):Vec3;

    /** Performs linear interpolation between x and y using a for each component. */
    public static overload function mix(x:Vec3, y:Vec3, a:Vec3):Vec3;

    /** Performs linear interpolation between x and y using a. Returns x*(1-a) + y*a component-wise. */
    public static overload function mix(x:Vec4, y:Vec4, a:Float):Vec4;

    /** Performs linear interpolation between x and y using a for each component. */
    public static overload function mix(x:Vec4, y:Vec4, a:Vec4):Vec4;

    /** Returns 0.0 if x < edge, otherwise returns 1.0. */
    public static overload function step(edge:Float, x:Float):Float;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, for each component. */
    public static overload function step(edge:Float, x:Vec2):Vec2;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, component-wise. */
    public static overload function step(edge:Vec2, x:Vec2):Vec2;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, for each component. */
    public static overload function step(edge:Float, x:Vec3):Vec3;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, component-wise. */
    public static overload function step(edge:Vec3, x:Vec3):Vec3;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, for each component. */
    public static overload function step(edge:Float, x:Vec4):Vec4;

    /** Returns 0.0 if x < edge, otherwise returns 1.0, component-wise. */
    public static overload function step(edge:Vec4, x:Vec4):Vec4;

    /** Performs smooth Hermite interpolation between 0 and 1 when edge0 < x < edge1. Returns 0 if x <= edge0, 1 if x >= edge1. Uses formula: t*t*(3-2*t) where t = clamp((x-edge0)/(edge1-edge0), 0, 1). */
    public static overload function smoothstep(edge0:Float, edge1:Float, x:Float):Float;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component. */
    public static overload function smoothstep(edge0:Float, edge1:Float, x:Vec2):Vec2;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component with per-component edges. */
    public static overload function smoothstep(edge0:Vec2, edge1:Vec2, x:Vec2):Vec2;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component. */
    public static overload function smoothstep(edge0:Float, edge1:Float, x:Vec3):Vec3;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component with per-component edges. */
    public static overload function smoothstep(edge0:Vec3, edge1:Vec3, x:Vec3):Vec3;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component. */
    public static overload function smoothstep(edge0:Float, edge1:Float, x:Vec4):Vec4;

    /** Performs smooth Hermite interpolation between 0 and 1 for each component with per-component edges. */
    public static overload function smoothstep(edge0:Vec4, edge1:Vec4, x:Vec4):Vec4;

    // ============================================================
    // Geometric Functions
    // ============================================================

    /** Returns the length (magnitude) of a scalar value (its absolute value). */
    public static overload function length(x:Float):Float;

    /** Returns the length (magnitude) of the vector. Computed as sqrt(x*x + y*y). */
    public static overload function length(x:Vec2):Float;

    /** Returns the length (magnitude) of the vector. Computed as sqrt(x*x + y*y + z*z). */
    public static overload function length(x:Vec3):Float;

    /** Returns the length (magnitude) of the vector. Computed as sqrt(x*x + y*y + z*z + w*w). */
    public static overload function length(x:Vec4):Float;

    /** Returns the distance between two scalar values. */
    public static overload function distance(p0:Float, p1:Float):Float;

    /** Returns the distance between two points. Computed as length(p0 - p1). */
    public static overload function distance(p0:Vec2, p1:Vec2):Float;

    /** Returns the distance between two points. Computed as length(p0 - p1). */
    public static overload function distance(p0:Vec3, p1:Vec3):Float;

    /** Returns the distance between two points. Computed as length(p0 - p1). */
    public static overload function distance(p0:Vec4, p1:Vec4):Float;

    /** Returns the dot product of two scalar values. */
    public static overload function dot(x:Float, y:Float):Float;

    /** Returns the dot product of two vectors. Computed as x.x*y.x + x.y*y.y. */
    public static overload function dot(x:Vec2, y:Vec2):Float;

    /** Returns the dot product of two vectors. Computed as x.x*y.x + x.y*y.y + x.z*y.z. */
    public static overload function dot(x:Vec3, y:Vec3):Float;

    /** Returns the dot product of two vectors. Computed as x.x*y.x + x.y*y.y + x.z*y.z + x.w*y.w. */
    public static overload function dot(x:Vec4, y:Vec4):Float;

    /** Returns the cross product of two 3-component vectors. The result is perpendicular to both input vectors. */
    public static function cross(x:Vec3, y:Vec3):Vec3;

    /** Returns a normalized scalar (1.0 if x >= 0, -1.0 otherwise). */
    public static overload function normalize(x:Float):Float;

    /** Returns a unit vector in the same direction as x. Computed as x / length(x). */
    public static overload function normalize(x:Vec2):Vec2;

    /** Returns a unit vector in the same direction as x. Computed as x / length(x). */
    public static overload function normalize(x:Vec3):Vec3;

    /** Returns a unit vector in the same direction as x. Computed as x / length(x). */
    public static overload function normalize(x:Vec4):Vec4;

    /** Returns N if dot(Nref, I) < 0, otherwise returns -N. Used to orient a normal to face the viewer. */
    public static overload function faceforward(N:Float, I:Float, Nref:Float):Float;

    /** Returns N if dot(Nref, I) < 0, otherwise returns -N. Used to orient a normal to face the viewer. */
    public static overload function faceforward(N:Vec2, I:Vec2, Nref:Vec2):Vec2;

    /** Returns N if dot(Nref, I) < 0, otherwise returns -N. Used to orient a normal to face the viewer. */
    public static overload function faceforward(N:Vec3, I:Vec3, Nref:Vec3):Vec3;

    /** Returns N if dot(Nref, I) < 0, otherwise returns -N. Used to orient a normal to face the viewer. */
    public static overload function faceforward(N:Vec4, I:Vec4, Nref:Vec4):Vec4;

    /** Returns the reflection direction for an incident vector I and surface normal N. Computed as I - 2*dot(N,I)*N. N should be normalized. */
    public static overload function reflect(I:Float, N:Float):Float;

    /** Returns the reflection direction for an incident vector I and surface normal N. Computed as I - 2*dot(N,I)*N. N should be normalized. */
    public static overload function reflect(I:Vec2, N:Vec2):Vec2;

    /** Returns the reflection direction for an incident vector I and surface normal N. Computed as I - 2*dot(N,I)*N. N should be normalized. */
    public static overload function reflect(I:Vec3, N:Vec3):Vec3;

    /** Returns the reflection direction for an incident vector I and surface normal N. Computed as I - 2*dot(N,I)*N. N should be normalized. */
    public static overload function reflect(I:Vec4, N:Vec4):Vec4;

    /** Returns the refraction direction for an incident vector I, surface normal N, and ratio of indices of refraction eta. I and N should be normalized. Returns zero vector if total internal reflection occurs. */
    public static overload function refract(I:Vec2, N:Vec2, eta:Float):Vec2;

    /** Returns the refraction direction for an incident vector I, surface normal N, and ratio of indices of refraction eta. I and N should be normalized. Returns zero vector if total internal reflection occurs. */
    public static overload function refract(I:Vec3, N:Vec3, eta:Float):Vec3;

    /** Returns the refraction direction for an incident vector I, surface normal N, and ratio of indices of refraction eta. I and N should be normalized. Returns zero vector if total internal reflection occurs. */
    public static overload function refract(I:Vec4, N:Vec4, eta:Float):Vec4;

    // ============================================================
    // Matrix Functions
    // ============================================================

    /** Performs component-wise multiplication of two matrices. This is NOT standard matrix multiplication - use the * operator for that. */
    public static overload function matrixCompMult(x:Mat2, y:Mat2):Mat2;

    /** Performs component-wise multiplication of two matrices. This is NOT standard matrix multiplication - use the * operator for that. */
    public static overload function matrixCompMult(x:Mat3, y:Mat3):Mat3;

    /** Performs component-wise multiplication of two matrices. This is NOT standard matrix multiplication - use the * operator for that. */
    public static overload function matrixCompMult(x:Mat4, y:Mat4):Mat4;

    /** Returns the transpose of the matrix (rows become columns, columns become rows). */
    public static overload function transpose(m:Mat2):Mat2;

    /** Returns the transpose of the matrix (rows become columns, columns become rows). */
    public static overload function transpose(m:Mat3):Mat3;

    /** Returns the transpose of the matrix (rows become columns, columns become rows). */
    public static overload function transpose(m:Mat4):Mat4;

    /** Returns the determinant of the matrix. */
    public static overload function determinant(m:Mat2):Float;

    /** Returns the determinant of the matrix. */
    public static overload function determinant(m:Mat3):Float;

    /** Returns the inverse of the matrix. Results are undefined if the matrix is singular (determinant is zero). */
    public static overload function inverse(m:Mat2):Mat2;

}