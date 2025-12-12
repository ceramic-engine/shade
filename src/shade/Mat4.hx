package shade;

#if (!macro && shade_for_haxe)
abstract IMat4(Any) {}
#else
extern class IMat4 {}
#end

abstract Mat4(IMat4) {
    // Column-major storage
    public function new(
        m00:Float = 1, m10:Float = 0, m20:Float = 0, m30:Float = 0,
        m01:Float = 0, m11:Float = 1, m21:Float = 0, m31:Float = 0,
        m02:Float = 0, m12:Float = 0, m22:Float = 1, m32:Float = 0,
        m03:Float = 0, m13:Float = 0, m23:Float = 0, m33:Float = 1
    ) {
        this = null;
    }

    // Create identity matrix
    public static function identity():Mat4 { return null; }

    // Create from diagonal value
    public static function fromDiagonal(v:Float):Mat4 { return null; }

    // Create from column vectors
    public static function fromColumns(col0:Vec4, col1:Vec4, col2:Vec4, col3:Vec4):Mat4 { return null; }

    // Column access
    public function getColumn(i:Int):Vec4 { return null; }
    public function setColumn(i:Int, v:Vec4):Void {}

    // Element access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }

    // Operators
    @:op(A + B) static function add(a:Mat4, b:Mat4):Mat4 { return null; }
    @:op(A - B) static function sub(a:Mat4, b:Mat4):Mat4 { return null; }
    @:op(A * B) static function mul(a:Mat4, b:Mat4):Mat4 { return null; }
    @:op(A * B) static function mulVec(a:Mat4, b:Vec4):Vec4 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Mat4, b:Float):Mat4 { return null; }
    @:op(-A) static function neg(a:Mat4):Mat4 { return null; }

    // Transpose
    public function transpose():Mat4 { return null; }
}
