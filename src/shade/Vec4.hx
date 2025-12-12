package shade;

#if (!macro && shade_for_haxe)
abstract IVec4(Any) {}
#else
extern class IVec4 {}
#end

abstract Vec4(IVec4) {
    public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) {
        this = null;
    }

    // Component access - xyzw
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var w(get, set):Float;

    function get_x():Float { return 0.0; }
    function set_x(v:Float):Float { return v; }
    function get_y():Float { return 0.0; }
    function set_y(v:Float):Float { return v; }
    function get_z():Float { return 0.0; }
    function set_z(v:Float):Float { return v; }
    function get_w():Float { return 0.0; }
    function set_w(v:Float):Float { return v; }

    // Component access - rgba (aliases)
    public var r(get, set):Float;
    public var g(get, set):Float;
    public var b(get, set):Float;
    public var a(get, set):Float;

    function get_r():Float { return 0.0; }
    function set_r(v:Float):Float { return v; }
    function get_g():Float { return 0.0; }
    function set_g(v:Float):Float { return v; }
    function get_b():Float { return 0.0; }
    function set_b(v:Float):Float { return v; }
    function get_a():Float { return 0.0; }
    function set_a(v:Float):Float { return v; }

    // Component access - stpq (aliases)
    public var s(get, set):Float;
    public var t(get, set):Float;
    public var p(get, set):Float;
    public var q(get, set):Float;

    function get_s():Float { return 0.0; }
    function set_s(v:Float):Float { return v; }
    function get_t():Float { return 0.0; }
    function set_t(v:Float):Float { return v; }
    function get_p():Float { return 0.0; }
    function set_p(v:Float):Float { return v; }
    function get_q():Float { return 0.0; }
    function set_q(v:Float):Float { return v; }

    // Vec2 swizzles (xyzw) - common ones
    public var xx(get, never):Vec2;
    function get_xx():Vec2 { return null; }
    public var xy(get, set):Vec2;
    function get_xy():Vec2 { return null; }
    function set_xy(v:Vec2):Vec2 { return v; }
    public var xz(get, set):Vec2;
    function get_xz():Vec2 { return null; }
    function set_xz(v:Vec2):Vec2 { return v; }
    public var xw(get, set):Vec2;
    function get_xw():Vec2 { return null; }
    function set_xw(v:Vec2):Vec2 { return v; }
    public var yx(get, set):Vec2;
    function get_yx():Vec2 { return null; }
    function set_yx(v:Vec2):Vec2 { return v; }
    public var yy(get, never):Vec2;
    function get_yy():Vec2 { return null; }
    public var yz(get, set):Vec2;
    function get_yz():Vec2 { return null; }
    function set_yz(v:Vec2):Vec2 { return v; }
    public var yw(get, set):Vec2;
    function get_yw():Vec2 { return null; }
    function set_yw(v:Vec2):Vec2 { return v; }
    public var zx(get, set):Vec2;
    function get_zx():Vec2 { return null; }
    function set_zx(v:Vec2):Vec2 { return v; }
    public var zy(get, set):Vec2;
    function get_zy():Vec2 { return null; }
    function set_zy(v:Vec2):Vec2 { return v; }
    public var zz(get, never):Vec2;
    function get_zz():Vec2 { return null; }
    public var zw(get, set):Vec2;
    function get_zw():Vec2 { return null; }
    function set_zw(v:Vec2):Vec2 { return v; }
    public var wx(get, set):Vec2;
    function get_wx():Vec2 { return null; }
    function set_wx(v:Vec2):Vec2 { return v; }
    public var wy(get, set):Vec2;
    function get_wy():Vec2 { return null; }
    function set_wy(v:Vec2):Vec2 { return v; }
    public var wz(get, set):Vec2;
    function get_wz():Vec2 { return null; }
    function set_wz(v:Vec2):Vec2 { return v; }
    public var ww(get, never):Vec2;
    function get_ww():Vec2 { return null; }

    // Vec2 swizzles (rgba)
    public var rr(get, never):Vec2;
    function get_rr():Vec2 { return null; }
    public var rg(get, set):Vec2;
    function get_rg():Vec2 { return null; }
    function set_rg(v:Vec2):Vec2 { return v; }
    public var rb(get, set):Vec2;
    function get_rb():Vec2 { return null; }
    function set_rb(v:Vec2):Vec2 { return v; }
    public var ra(get, set):Vec2;
    function get_ra():Vec2 { return null; }
    function set_ra(v:Vec2):Vec2 { return v; }
    public var gr(get, set):Vec2;
    function get_gr():Vec2 { return null; }
    function set_gr(v:Vec2):Vec2 { return v; }
    public var gg(get, never):Vec2;
    function get_gg():Vec2 { return null; }
    public var gb(get, set):Vec2;
    function get_gb():Vec2 { return null; }
    function set_gb(v:Vec2):Vec2 { return v; }
    public var ga(get, set):Vec2;
    function get_ga():Vec2 { return null; }
    function set_ga(v:Vec2):Vec2 { return v; }
    public var br(get, set):Vec2;
    function get_br():Vec2 { return null; }
    function set_br(v:Vec2):Vec2 { return v; }
    public var bg(get, set):Vec2;
    function get_bg():Vec2 { return null; }
    function set_bg(v:Vec2):Vec2 { return v; }
    public var bb(get, never):Vec2;
    function get_bb():Vec2 { return null; }
    public var ba(get, set):Vec2;
    function get_ba():Vec2 { return null; }
    function set_ba(v:Vec2):Vec2 { return v; }
    public var ar(get, set):Vec2;
    function get_ar():Vec2 { return null; }
    function set_ar(v:Vec2):Vec2 { return v; }
    public var ag(get, set):Vec2;
    function get_ag():Vec2 { return null; }
    function set_ag(v:Vec2):Vec2 { return v; }
    public var ab(get, set):Vec2;
    function get_ab():Vec2 { return null; }
    function set_ab(v:Vec2):Vec2 { return v; }
    public var aa(get, never):Vec2;
    function get_aa():Vec2 { return null; }

    // Vec2 swizzles (stpq)
    public var ss(get, never):Vec2;
    function get_ss():Vec2 { return null; }
    public var st(get, set):Vec2;
    function get_st():Vec2 { return null; }
    function set_st(v:Vec2):Vec2 { return v; }
    public var sp(get, set):Vec2;
    function get_sp():Vec2 { return null; }
    function set_sp(v:Vec2):Vec2 { return v; }
    public var sq(get, set):Vec2;
    function get_sq():Vec2 { return null; }
    function set_sq(v:Vec2):Vec2 { return v; }
    public var ts(get, set):Vec2;
    function get_ts():Vec2 { return null; }
    function set_ts(v:Vec2):Vec2 { return v; }
    public var tt(get, never):Vec2;
    function get_tt():Vec2 { return null; }
    public var tp(get, set):Vec2;
    function get_tp():Vec2 { return null; }
    function set_tp(v:Vec2):Vec2 { return v; }
    public var tq(get, set):Vec2;
    function get_tq():Vec2 { return null; }
    function set_tq(v:Vec2):Vec2 { return v; }
    public var ps(get, set):Vec2;
    function get_ps():Vec2 { return null; }
    function set_ps(v:Vec2):Vec2 { return v; }
    public var pt(get, set):Vec2;
    function get_pt():Vec2 { return null; }
    function set_pt(v:Vec2):Vec2 { return v; }
    public var pp(get, never):Vec2;
    function get_pp():Vec2 { return null; }
    public var pq(get, set):Vec2;
    function get_pq():Vec2 { return null; }
    function set_pq(v:Vec2):Vec2 { return v; }
    public var qs(get, set):Vec2;
    function get_qs():Vec2 { return null; }
    function set_qs(v:Vec2):Vec2 { return v; }
    public var qt(get, set):Vec2;
    function get_qt():Vec2 { return null; }
    function set_qt(v:Vec2):Vec2 { return v; }
    public var qp(get, set):Vec2;
    function get_qp():Vec2 { return null; }
    function set_qp(v:Vec2):Vec2 { return v; }
    public var qq(get, never):Vec2;
    function get_qq():Vec2 { return null; }

    // Vec3 swizzles (xyzw) - common ones
    public var xyz(get, set):Vec3;
    function get_xyz():Vec3 { return null; }
    function set_xyz(v:Vec3):Vec3 { return v; }
    public var xyw(get, set):Vec3;
    function get_xyw():Vec3 { return null; }
    function set_xyw(v:Vec3):Vec3 { return v; }
    public var xzy(get, set):Vec3;
    function get_xzy():Vec3 { return null; }
    function set_xzy(v:Vec3):Vec3 { return v; }
    public var xzw(get, set):Vec3;
    function get_xzw():Vec3 { return null; }
    function set_xzw(v:Vec3):Vec3 { return v; }
    public var xwy(get, set):Vec3;
    function get_xwy():Vec3 { return null; }
    function set_xwy(v:Vec3):Vec3 { return v; }
    public var xwz(get, set):Vec3;
    function get_xwz():Vec3 { return null; }
    function set_xwz(v:Vec3):Vec3 { return v; }
    public var yxz(get, set):Vec3;
    function get_yxz():Vec3 { return null; }
    function set_yxz(v:Vec3):Vec3 { return v; }
    public var yxw(get, set):Vec3;
    function get_yxw():Vec3 { return null; }
    function set_yxw(v:Vec3):Vec3 { return v; }
    public var yzx(get, set):Vec3;
    function get_yzx():Vec3 { return null; }
    function set_yzx(v:Vec3):Vec3 { return v; }
    public var yzw(get, set):Vec3;
    function get_yzw():Vec3 { return null; }
    function set_yzw(v:Vec3):Vec3 { return v; }
    public var ywx(get, set):Vec3;
    function get_ywx():Vec3 { return null; }
    function set_ywx(v:Vec3):Vec3 { return v; }
    public var ywz(get, set):Vec3;
    function get_ywz():Vec3 { return null; }
    function set_ywz(v:Vec3):Vec3 { return v; }
    public var zxy(get, set):Vec3;
    function get_zxy():Vec3 { return null; }
    function set_zxy(v:Vec3):Vec3 { return v; }
    public var zxw(get, set):Vec3;
    function get_zxw():Vec3 { return null; }
    function set_zxw(v:Vec3):Vec3 { return v; }
    public var zyx(get, set):Vec3;
    function get_zyx():Vec3 { return null; }
    function set_zyx(v:Vec3):Vec3 { return v; }
    public var zyw(get, set):Vec3;
    function get_zyw():Vec3 { return null; }
    function set_zyw(v:Vec3):Vec3 { return v; }
    public var zwx(get, set):Vec3;
    function get_zwx():Vec3 { return null; }
    function set_zwx(v:Vec3):Vec3 { return v; }
    public var zwy(get, set):Vec3;
    function get_zwy():Vec3 { return null; }
    function set_zwy(v:Vec3):Vec3 { return v; }
    public var wxy(get, set):Vec3;
    function get_wxy():Vec3 { return null; }
    function set_wxy(v:Vec3):Vec3 { return v; }
    public var wxz(get, set):Vec3;
    function get_wxz():Vec3 { return null; }
    function set_wxz(v:Vec3):Vec3 { return v; }
    public var wyx(get, set):Vec3;
    function get_wyx():Vec3 { return null; }
    function set_wyx(v:Vec3):Vec3 { return v; }
    public var wyz(get, set):Vec3;
    function get_wyz():Vec3 { return null; }
    function set_wyz(v:Vec3):Vec3 { return v; }
    public var wzx(get, set):Vec3;
    function get_wzx():Vec3 { return null; }
    function set_wzx(v:Vec3):Vec3 { return v; }
    public var wzy(get, set):Vec3;
    function get_wzy():Vec3 { return null; }
    function set_wzy(v:Vec3):Vec3 { return v; }

    // Vec3 swizzles (rgba) - common ones
    public var rgb(get, set):Vec3;
    function get_rgb():Vec3 { return null; }
    function set_rgb(v:Vec3):Vec3 { return v; }
    public var rga(get, set):Vec3;
    function get_rga():Vec3 { return null; }
    function set_rga(v:Vec3):Vec3 { return v; }
    public var rbg(get, set):Vec3;
    function get_rbg():Vec3 { return null; }
    function set_rbg(v:Vec3):Vec3 { return v; }
    public var rba(get, set):Vec3;
    function get_rba():Vec3 { return null; }
    function set_rba(v:Vec3):Vec3 { return v; }
    public var rag(get, set):Vec3;
    function get_rag():Vec3 { return null; }
    function set_rag(v:Vec3):Vec3 { return v; }
    public var rab(get, set):Vec3;
    function get_rab():Vec3 { return null; }
    function set_rab(v:Vec3):Vec3 { return v; }
    public var grb(get, set):Vec3;
    function get_grb():Vec3 { return null; }
    function set_grb(v:Vec3):Vec3 { return v; }
    public var gra(get, set):Vec3;
    function get_gra():Vec3 { return null; }
    function set_gra(v:Vec3):Vec3 { return v; }
    public var gbr(get, set):Vec3;
    function get_gbr():Vec3 { return null; }
    function set_gbr(v:Vec3):Vec3 { return v; }
    public var gba(get, set):Vec3;
    function get_gba():Vec3 { return null; }
    function set_gba(v:Vec3):Vec3 { return v; }
    public var gar(get, set):Vec3;
    function get_gar():Vec3 { return null; }
    function set_gar(v:Vec3):Vec3 { return v; }
    public var gab(get, set):Vec3;
    function get_gab():Vec3 { return null; }
    function set_gab(v:Vec3):Vec3 { return v; }
    public var brg(get, set):Vec3;
    function get_brg():Vec3 { return null; }
    function set_brg(v:Vec3):Vec3 { return v; }
    public var bra(get, set):Vec3;
    function get_bra():Vec3 { return null; }
    function set_bra(v:Vec3):Vec3 { return v; }
    public var bgr(get, set):Vec3;
    function get_bgr():Vec3 { return null; }
    function set_bgr(v:Vec3):Vec3 { return v; }
    public var bga(get, set):Vec3;
    function get_bga():Vec3 { return null; }
    function set_bga(v:Vec3):Vec3 { return v; }
    public var bar(get, set):Vec3;
    function get_bar():Vec3 { return null; }
    function set_bar(v:Vec3):Vec3 { return v; }
    public var bag(get, set):Vec3;
    function get_bag():Vec3 { return null; }
    function set_bag(v:Vec3):Vec3 { return v; }
    public var arg(get, set):Vec3;
    function get_arg():Vec3 { return null; }
    function set_arg(v:Vec3):Vec3 { return v; }
    public var arb(get, set):Vec3;
    function get_arb():Vec3 { return null; }
    function set_arb(v:Vec3):Vec3 { return v; }
    public var agr(get, set):Vec3;
    function get_agr():Vec3 { return null; }
    function set_agr(v:Vec3):Vec3 { return v; }
    public var agb(get, set):Vec3;
    function get_agb():Vec3 { return null; }
    function set_agb(v:Vec3):Vec3 { return v; }
    public var abr(get, set):Vec3;
    function get_abr():Vec3 { return null; }
    function set_abr(v:Vec3):Vec3 { return v; }
    public var abg(get, set):Vec3;
    function get_abg():Vec3 { return null; }
    function set_abg(v:Vec3):Vec3 { return v; }

    // Vec4 swizzles (xyzw) - common ones
    public var xyzw(get, set):Vec4;
    function get_xyzw():Vec4 { return null; }
    function set_xyzw(v:Vec4):Vec4 { return v; }
    public var xywz(get, set):Vec4;
    function get_xywz():Vec4 { return null; }
    function set_xywz(v:Vec4):Vec4 { return v; }
    public var xzyw(get, set):Vec4;
    function get_xzyw():Vec4 { return null; }
    function set_xzyw(v:Vec4):Vec4 { return v; }
    public var xzwy(get, set):Vec4;
    function get_xzwy():Vec4 { return null; }
    function set_xzwy(v:Vec4):Vec4 { return v; }
    public var xwyz(get, set):Vec4;
    function get_xwyz():Vec4 { return null; }
    function set_xwyz(v:Vec4):Vec4 { return v; }
    public var xwzy(get, set):Vec4;
    function get_xwzy():Vec4 { return null; }
    function set_xwzy(v:Vec4):Vec4 { return v; }
    public var yxzw(get, set):Vec4;
    function get_yxzw():Vec4 { return null; }
    function set_yxzw(v:Vec4):Vec4 { return v; }
    public var yxwz(get, set):Vec4;
    function get_yxwz():Vec4 { return null; }
    function set_yxwz(v:Vec4):Vec4 { return v; }
    public var yzxw(get, set):Vec4;
    function get_yzxw():Vec4 { return null; }
    function set_yzxw(v:Vec4):Vec4 { return v; }
    public var yzwx(get, set):Vec4;
    function get_yzwx():Vec4 { return null; }
    function set_yzwx(v:Vec4):Vec4 { return v; }
    public var ywxz(get, set):Vec4;
    function get_ywxz():Vec4 { return null; }
    function set_ywxz(v:Vec4):Vec4 { return v; }
    public var ywzx(get, set):Vec4;
    function get_ywzx():Vec4 { return null; }
    function set_ywzx(v:Vec4):Vec4 { return v; }
    public var zxyw(get, set):Vec4;
    function get_zxyw():Vec4 { return null; }
    function set_zxyw(v:Vec4):Vec4 { return v; }
    public var zxwy(get, set):Vec4;
    function get_zxwy():Vec4 { return null; }
    function set_zxwy(v:Vec4):Vec4 { return v; }
    public var zyxw(get, set):Vec4;
    function get_zyxw():Vec4 { return null; }
    function set_zyxw(v:Vec4):Vec4 { return v; }
    public var zywx(get, set):Vec4;
    function get_zywx():Vec4 { return null; }
    function set_zywx(v:Vec4):Vec4 { return v; }
    public var zwxy(get, set):Vec4;
    function get_zwxy():Vec4 { return null; }
    function set_zwxy(v:Vec4):Vec4 { return v; }
    public var zwyx(get, set):Vec4;
    function get_zwyx():Vec4 { return null; }
    function set_zwyx(v:Vec4):Vec4 { return v; }
    public var wxyz(get, set):Vec4;
    function get_wxyz():Vec4 { return null; }
    function set_wxyz(v:Vec4):Vec4 { return v; }
    public var wxzy(get, set):Vec4;
    function get_wxzy():Vec4 { return null; }
    function set_wxzy(v:Vec4):Vec4 { return v; }
    public var wyxz(get, set):Vec4;
    function get_wyxz():Vec4 { return null; }
    function set_wyxz(v:Vec4):Vec4 { return v; }
    public var wyzx(get, set):Vec4;
    function get_wyzx():Vec4 { return null; }
    function set_wyzx(v:Vec4):Vec4 { return v; }
    public var wzxy(get, set):Vec4;
    function get_wzxy():Vec4 { return null; }
    function set_wzxy(v:Vec4):Vec4 { return v; }
    public var wzyx(get, set):Vec4;
    function get_wzyx():Vec4 { return null; }
    function set_wzyx(v:Vec4):Vec4 { return v; }

    // Vec4 swizzles (rgba) - common ones
    public var rgba(get, set):Vec4;
    function get_rgba():Vec4 { return null; }
    function set_rgba(v:Vec4):Vec4 { return v; }
    public var rgab(get, set):Vec4;
    function get_rgab():Vec4 { return null; }
    function set_rgab(v:Vec4):Vec4 { return v; }
    public var rbga(get, set):Vec4;
    function get_rbga():Vec4 { return null; }
    function set_rbga(v:Vec4):Vec4 { return v; }
    public var rbag(get, set):Vec4;
    function get_rbag():Vec4 { return null; }
    function set_rbag(v:Vec4):Vec4 { return v; }
    public var ragb(get, set):Vec4;
    function get_ragb():Vec4 { return null; }
    function set_ragb(v:Vec4):Vec4 { return v; }
    public var rabg(get, set):Vec4;
    function get_rabg():Vec4 { return null; }
    function set_rabg(v:Vec4):Vec4 { return v; }
    public var grba(get, set):Vec4;
    function get_grba():Vec4 { return null; }
    function set_grba(v:Vec4):Vec4 { return v; }
    public var grab(get, set):Vec4;
    function get_grab():Vec4 { return null; }
    function set_grab(v:Vec4):Vec4 { return v; }
    public var gbra(get, set):Vec4;
    function get_gbra():Vec4 { return null; }
    function set_gbra(v:Vec4):Vec4 { return v; }
    public var gbar(get, set):Vec4;
    function get_gbar():Vec4 { return null; }
    function set_gbar(v:Vec4):Vec4 { return v; }
    public var garb(get, set):Vec4;
    function get_garb():Vec4 { return null; }
    function set_garb(v:Vec4):Vec4 { return v; }
    public var gabr(get, set):Vec4;
    function get_gabr():Vec4 { return null; }
    function set_gabr(v:Vec4):Vec4 { return v; }
    public var brga(get, set):Vec4;
    function get_brga():Vec4 { return null; }
    function set_brga(v:Vec4):Vec4 { return v; }
    public var brag(get, set):Vec4;
    function get_brag():Vec4 { return null; }
    function set_brag(v:Vec4):Vec4 { return v; }
    public var bgra(get, set):Vec4;
    function get_bgra():Vec4 { return null; }
    function set_bgra(v:Vec4):Vec4 { return v; }
    public var bgar(get, set):Vec4;
    function get_bgar():Vec4 { return null; }
    function set_bgar(v:Vec4):Vec4 { return v; }
    public var barg(get, set):Vec4;
    function get_barg():Vec4 { return null; }
    function set_barg(v:Vec4):Vec4 { return v; }
    public var bagr(get, set):Vec4;
    function get_bagr():Vec4 { return null; }
    function set_bagr(v:Vec4):Vec4 { return v; }
    public var argb(get, set):Vec4;
    function get_argb():Vec4 { return null; }
    function set_argb(v:Vec4):Vec4 { return v; }
    public var arbg(get, set):Vec4;
    function get_arbg():Vec4 { return null; }
    function set_arbg(v:Vec4):Vec4 { return v; }
    public var agrb(get, set):Vec4;
    function get_agrb():Vec4 { return null; }
    function set_agrb(v:Vec4):Vec4 { return v; }
    public var agbr(get, set):Vec4;
    function get_agbr():Vec4 { return null; }
    function set_agbr(v:Vec4):Vec4 { return v; }
    public var abrg(get, set):Vec4;
    function get_abrg():Vec4 { return null; }
    function set_abrg(v:Vec4):Vec4 { return v; }
    public var abgr(get, set):Vec4;
    function get_abgr():Vec4 { return null; }
    function set_abgr(v:Vec4):Vec4 { return v; }

    // Operators
    @:op(A + B) static function add(a:Vec4, b:Vec4):Vec4 { return null; }
    @:op(A - B) static function sub(a:Vec4, b:Vec4):Vec4 { return null; }
    @:op(A * B) static function mul(a:Vec4, b:Vec4):Vec4 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Vec4, b:Float):Vec4 { return null; }
    @:op(A / B) static function div(a:Vec4, b:Vec4):Vec4 { return null; }
    @:op(A / B) static function divScalar(a:Vec4, b:Float):Vec4 { return null; }
    @:op(-A) static function neg(a:Vec4):Vec4 { return null; }

    // Array access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }
}
