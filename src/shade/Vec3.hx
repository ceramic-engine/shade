package shade;

extern class IVec3 {}

abstract Vec3(IVec3) {
    public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
        this = null;
    }

    // Component access - xyzw
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;

    function get_x():Float { return 0.0; }
    function set_x(v:Float):Float { return v; }
    function get_y():Float { return 0.0; }
    function set_y(v:Float):Float { return v; }
    function get_z():Float { return 0.0; }
    function set_z(v:Float):Float { return v; }

    // Component access - rgba (aliases)
    public var r(get, set):Float;
    public var g(get, set):Float;
    public var b(get, set):Float;

    function get_r():Float { return 0.0; }
    function set_r(v:Float):Float { return v; }
    function get_g():Float { return 0.0; }
    function set_g(v:Float):Float { return v; }
    function get_b():Float { return 0.0; }
    function set_b(v:Float):Float { return v; }

    // Component access - stpq (aliases)
    public var s(get, set):Float;
    public var t(get, set):Float;
    public var p(get, set):Float;

    function get_s():Float { return 0.0; }
    function set_s(v:Float):Float { return v; }
    function get_t():Float { return 0.0; }
    function set_t(v:Float):Float { return v; }
    function get_p():Float { return 0.0; }
    function set_p(v:Float):Float { return v; }

    // Vec2 swizzles (xyzw)
    public var xx(get, never):Vec2;
    function get_xx():Vec2 { return null; }
    public var xy(get, set):Vec2;
    function get_xy():Vec2 { return null; }
    function set_xy(v:Vec2):Vec2 { return v; }
    public var xz(get, set):Vec2;
    function get_xz():Vec2 { return null; }
    function set_xz(v:Vec2):Vec2 { return v; }
    public var yx(get, set):Vec2;
    function get_yx():Vec2 { return null; }
    function set_yx(v:Vec2):Vec2 { return v; }
    public var yy(get, never):Vec2;
    function get_yy():Vec2 { return null; }
    public var yz(get, set):Vec2;
    function get_yz():Vec2 { return null; }
    function set_yz(v:Vec2):Vec2 { return v; }
    public var zx(get, set):Vec2;
    function get_zx():Vec2 { return null; }
    function set_zx(v:Vec2):Vec2 { return v; }
    public var zy(get, set):Vec2;
    function get_zy():Vec2 { return null; }
    function set_zy(v:Vec2):Vec2 { return v; }
    public var zz(get, never):Vec2;
    function get_zz():Vec2 { return null; }

    // Vec2 swizzles (rgba)
    public var rr(get, never):Vec2;
    function get_rr():Vec2 { return null; }
    public var rg(get, set):Vec2;
    function get_rg():Vec2 { return null; }
    function set_rg(v:Vec2):Vec2 { return v; }
    public var rb(get, set):Vec2;
    function get_rb():Vec2 { return null; }
    function set_rb(v:Vec2):Vec2 { return v; }
    public var gr(get, set):Vec2;
    function get_gr():Vec2 { return null; }
    function set_gr(v:Vec2):Vec2 { return v; }
    public var gg(get, never):Vec2;
    function get_gg():Vec2 { return null; }
    public var gb(get, set):Vec2;
    function get_gb():Vec2 { return null; }
    function set_gb(v:Vec2):Vec2 { return v; }
    public var br(get, set):Vec2;
    function get_br():Vec2 { return null; }
    function set_br(v:Vec2):Vec2 { return v; }
    public var bg(get, set):Vec2;
    function get_bg():Vec2 { return null; }
    function set_bg(v:Vec2):Vec2 { return v; }
    public var bb(get, never):Vec2;
    function get_bb():Vec2 { return null; }

    // Vec2 swizzles (stpq)
    public var ss(get, never):Vec2;
    function get_ss():Vec2 { return null; }
    public var st(get, set):Vec2;
    function get_st():Vec2 { return null; }
    function set_st(v:Vec2):Vec2 { return v; }
    public var sp(get, set):Vec2;
    function get_sp():Vec2 { return null; }
    function set_sp(v:Vec2):Vec2 { return v; }
    public var ts(get, set):Vec2;
    function get_ts():Vec2 { return null; }
    function set_ts(v:Vec2):Vec2 { return v; }
    public var tt(get, never):Vec2;
    function get_tt():Vec2 { return null; }
    public var tp(get, set):Vec2;
    function get_tp():Vec2 { return null; }
    function set_tp(v:Vec2):Vec2 { return v; }
    public var ps(get, set):Vec2;
    function get_ps():Vec2 { return null; }
    function set_ps(v:Vec2):Vec2 { return v; }
    public var pt(get, set):Vec2;
    function get_pt():Vec2 { return null; }
    function set_pt(v:Vec2):Vec2 { return v; }
    public var pp(get, never):Vec2;
    function get_pp():Vec2 { return null; }

    // Vec3 swizzles (xyzw)
    public var xxx(get, never):Vec3;
    function get_xxx():Vec3 { return null; }
    public var xxy(get, never):Vec3;
    function get_xxy():Vec3 { return null; }
    public var xxz(get, never):Vec3;
    function get_xxz():Vec3 { return null; }
    public var xyx(get, never):Vec3;
    function get_xyx():Vec3 { return null; }
    public var xyy(get, never):Vec3;
    function get_xyy():Vec3 { return null; }
    public var xyz(get, set):Vec3;
    function get_xyz():Vec3 { return null; }
    function set_xyz(v:Vec3):Vec3 { return v; }
    public var xzx(get, never):Vec3;
    function get_xzx():Vec3 { return null; }
    public var xzy(get, set):Vec3;
    function get_xzy():Vec3 { return null; }
    function set_xzy(v:Vec3):Vec3 { return v; }
    public var xzz(get, never):Vec3;
    function get_xzz():Vec3 { return null; }
    public var yxx(get, never):Vec3;
    function get_yxx():Vec3 { return null; }
    public var yxy(get, never):Vec3;
    function get_yxy():Vec3 { return null; }
    public var yxz(get, set):Vec3;
    function get_yxz():Vec3 { return null; }
    function set_yxz(v:Vec3):Vec3 { return v; }
    public var yyx(get, never):Vec3;
    function get_yyx():Vec3 { return null; }
    public var yyy(get, never):Vec3;
    function get_yyy():Vec3 { return null; }
    public var yyz(get, never):Vec3;
    function get_yyz():Vec3 { return null; }
    public var yzx(get, set):Vec3;
    function get_yzx():Vec3 { return null; }
    function set_yzx(v:Vec3):Vec3 { return v; }
    public var yzy(get, never):Vec3;
    function get_yzy():Vec3 { return null; }
    public var yzz(get, never):Vec3;
    function get_yzz():Vec3 { return null; }
    public var zxx(get, never):Vec3;
    function get_zxx():Vec3 { return null; }
    public var zxy(get, set):Vec3;
    function get_zxy():Vec3 { return null; }
    function set_zxy(v:Vec3):Vec3 { return v; }
    public var zxz(get, never):Vec3;
    function get_zxz():Vec3 { return null; }
    public var zyx(get, set):Vec3;
    function get_zyx():Vec3 { return null; }
    function set_zyx(v:Vec3):Vec3 { return v; }
    public var zyy(get, never):Vec3;
    function get_zyy():Vec3 { return null; }
    public var zyz(get, never):Vec3;
    function get_zyz():Vec3 { return null; }
    public var zzx(get, never):Vec3;
    function get_zzx():Vec3 { return null; }
    public var zzy(get, never):Vec3;
    function get_zzy():Vec3 { return null; }
    public var zzz(get, never):Vec3;
    function get_zzz():Vec3 { return null; }

    // Vec3 swizzles (rgba)
    public var rrr(get, never):Vec3;
    function get_rrr():Vec3 { return null; }
    public var rrg(get, never):Vec3;
    function get_rrg():Vec3 { return null; }
    public var rrb(get, never):Vec3;
    function get_rrb():Vec3 { return null; }
    public var rgr(get, never):Vec3;
    function get_rgr():Vec3 { return null; }
    public var rgg(get, never):Vec3;
    function get_rgg():Vec3 { return null; }
    public var rgb(get, set):Vec3;
    function get_rgb():Vec3 { return null; }
    function set_rgb(v:Vec3):Vec3 { return v; }
    public var rbr(get, never):Vec3;
    function get_rbr():Vec3 { return null; }
    public var rbg(get, set):Vec3;
    function get_rbg():Vec3 { return null; }
    function set_rbg(v:Vec3):Vec3 { return v; }
    public var rbb(get, never):Vec3;
    function get_rbb():Vec3 { return null; }
    public var grr(get, never):Vec3;
    function get_grr():Vec3 { return null; }
    public var grg(get, never):Vec3;
    function get_grg():Vec3 { return null; }
    public var grb(get, set):Vec3;
    function get_grb():Vec3 { return null; }
    function set_grb(v:Vec3):Vec3 { return v; }
    public var ggr(get, never):Vec3;
    function get_ggr():Vec3 { return null; }
    public var ggg(get, never):Vec3;
    function get_ggg():Vec3 { return null; }
    public var ggb(get, never):Vec3;
    function get_ggb():Vec3 { return null; }
    public var gbr(get, set):Vec3;
    function get_gbr():Vec3 { return null; }
    function set_gbr(v:Vec3):Vec3 { return v; }
    public var gbg(get, never):Vec3;
    function get_gbg():Vec3 { return null; }
    public var gbb(get, never):Vec3;
    function get_gbb():Vec3 { return null; }
    public var brr(get, never):Vec3;
    function get_brr():Vec3 { return null; }
    public var brg(get, set):Vec3;
    function get_brg():Vec3 { return null; }
    function set_brg(v:Vec3):Vec3 { return v; }
    public var brb(get, never):Vec3;
    function get_brb():Vec3 { return null; }
    public var bgr(get, set):Vec3;
    function get_bgr():Vec3 { return null; }
    function set_bgr(v:Vec3):Vec3 { return v; }
    public var bgg(get, never):Vec3;
    function get_bgg():Vec3 { return null; }
    public var bgb(get, never):Vec3;
    function get_bgb():Vec3 { return null; }
    public var bbr(get, never):Vec3;
    function get_bbr():Vec3 { return null; }
    public var bbg(get, never):Vec3;
    function get_bbg():Vec3 { return null; }
    public var bbb(get, never):Vec3;
    function get_bbb():Vec3 { return null; }

    // Vec3 swizzles (stpq)
    public var sss(get, never):Vec3;
    function get_sss():Vec3 { return null; }
    public var sst(get, never):Vec3;
    function get_sst():Vec3 { return null; }
    public var ssp(get, never):Vec3;
    function get_ssp():Vec3 { return null; }
    public var sts(get, never):Vec3;
    function get_sts():Vec3 { return null; }
    public var stt(get, never):Vec3;
    function get_stt():Vec3 { return null; }
    public var stp(get, set):Vec3;
    function get_stp():Vec3 { return null; }
    function set_stp(v:Vec3):Vec3 { return v; }
    public var sps(get, never):Vec3;
    function get_sps():Vec3 { return null; }
    public var spt(get, set):Vec3;
    function get_spt():Vec3 { return null; }
    function set_spt(v:Vec3):Vec3 { return v; }
    public var spp(get, never):Vec3;
    function get_spp():Vec3 { return null; }
    public var tss(get, never):Vec3;
    function get_tss():Vec3 { return null; }
    public var tst(get, never):Vec3;
    function get_tst():Vec3 { return null; }
    public var tsp(get, set):Vec3;
    function get_tsp():Vec3 { return null; }
    function set_tsp(v:Vec3):Vec3 { return v; }
    public var tts(get, never):Vec3;
    function get_tts():Vec3 { return null; }
    public var ttt(get, never):Vec3;
    function get_ttt():Vec3 { return null; }
    public var ttp(get, never):Vec3;
    function get_ttp():Vec3 { return null; }
    public var tps(get, set):Vec3;
    function get_tps():Vec3 { return null; }
    function set_tps(v:Vec3):Vec3 { return v; }
    public var tpt(get, never):Vec3;
    function get_tpt():Vec3 { return null; }
    public var tpp(get, never):Vec3;
    function get_tpp():Vec3 { return null; }
    public var pss(get, never):Vec3;
    function get_pss():Vec3 { return null; }
    public var pst(get, set):Vec3;
    function get_pst():Vec3 { return null; }
    function set_pst(v:Vec3):Vec3 { return v; }
    public var psp(get, never):Vec3;
    function get_psp():Vec3 { return null; }
    public var pts(get, set):Vec3;
    function get_pts():Vec3 { return null; }
    function set_pts(v:Vec3):Vec3 { return v; }
    public var ptt(get, never):Vec3;
    function get_ptt():Vec3 { return null; }
    public var ptp(get, never):Vec3;
    function get_ptp():Vec3 { return null; }
    public var pps(get, never):Vec3;
    function get_pps():Vec3 { return null; }
    public var ppt(get, never):Vec3;
    function get_ppt():Vec3 { return null; }
    public var ppp(get, never):Vec3;
    function get_ppp():Vec3 { return null; }

    // Operators
    @:op(A + B) static function add(a:Vec3, b:Vec3):Vec3 { return null; }
    @:op(A - B) static function sub(a:Vec3, b:Vec3):Vec3 { return null; }
    @:op(A * B) static function mul(a:Vec3, b:Vec3):Vec3 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Vec3, b:Float):Vec3 { return null; }
    @:op(A / B) static function div(a:Vec3, b:Vec3):Vec3 { return null; }
    @:op(A / B) static function divScalar(a:Vec3, b:Float):Vec3 { return null; }
    @:op(-A) static function neg(a:Vec3):Vec3 { return null; }

    // Array access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }
}
