package shade;

extern class IVec2 {}

abstract Vec2(IVec2) {
    public function new(x:Float = 0, y:Float = 0) {
        this = null;
    }

    // Component access - xyzw
    public var x(get, set):Float;
    public var y(get, set):Float;

    function get_x():Float { return 0.0; }
    function set_x(v:Float):Float { return v; }
    function get_y():Float { return 0.0; }
    function set_y(v:Float):Float { return v; }

    // Component access - rgba (aliases)
    public var r(get, set):Float;
    public var g(get, set):Float;

    function get_r():Float { return 0.0; }
    function set_r(v:Float):Float { return v; }
    function get_g():Float { return 0.0; }
    function set_g(v:Float):Float { return v; }

    // Component access - stpq (aliases)
    public var s(get, set):Float;
    public var t(get, set):Float;

    function get_s():Float { return 0.0; }
    function set_s(v:Float):Float { return v; }
    function get_t():Float { return 0.0; }
    function set_t(v:Float):Float { return v; }

    // Vec2 swizzles (xyzw)
    public var xx(get, never):Vec2;
    function get_xx():Vec2 { return null; }
    public var xy(get, set):Vec2;
    function get_xy():Vec2 { return null; }
    function set_xy(v:Vec2):Vec2 { return v; }
    public var yx(get, set):Vec2;
    function get_yx():Vec2 { return null; }
    function set_yx(v:Vec2):Vec2 { return v; }
    public var yy(get, never):Vec2;
    function get_yy():Vec2 { return null; }

    // Vec2 swizzles (rgba)
    public var rr(get, never):Vec2;
    function get_rr():Vec2 { return null; }
    public var rg(get, set):Vec2;
    function get_rg():Vec2 { return null; }
    function set_rg(v:Vec2):Vec2 { return v; }
    public var gr(get, set):Vec2;
    function get_gr():Vec2 { return null; }
    function set_gr(v:Vec2):Vec2 { return v; }
    public var gg(get, never):Vec2;
    function get_gg():Vec2 { return null; }

    // Vec2 swizzles (stpq)
    public var ss(get, never):Vec2;
    function get_ss():Vec2 { return null; }
    public var st(get, set):Vec2;
    function get_st():Vec2 { return null; }
    function set_st(v:Vec2):Vec2 { return v; }
    public var ts(get, set):Vec2;
    function get_ts():Vec2 { return null; }
    function set_ts(v:Vec2):Vec2 { return v; }
    public var tt(get, never):Vec2;
    function get_tt():Vec2 { return null; }

    // Operators
    @:op(A + B) static function add(a:Vec2, b:Vec2):Vec2 { return null; }
    @:op(A - B) static function sub(a:Vec2, b:Vec2):Vec2 { return null; }
    @:op(A * B) static function mul(a:Vec2, b:Vec2):Vec2 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Vec2, b:Float):Vec2 { return null; }
    @:op(A / B) static function div(a:Vec2, b:Vec2):Vec2 { return null; }
    @:op(A / B) static function divScalar(a:Vec2, b:Float):Vec2 { return null; }
    @:op(-A) static function neg(a:Vec2):Vec2 { return null; }

    // Array access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }
}
