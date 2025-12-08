package shade;

extern class IMat2 {}

abstract Mat2(IMat2) {
    // Column-major storage
    public function new(m00:Float = 1, m10:Float = 0, m01:Float = 0, m11:Float = 1) {
        this = null;
    }

    // Create identity matrix
    public static function identity():Mat2 { return null; }

    // Create from diagonal value
    public static function fromDiagonal(v:Float):Mat2 { return null; }

    // Create from column vectors
    public static function fromColumns(col0:Vec2, col1:Vec2):Mat2 { return null; }

    // Column access
    public function getColumn(i:Int):Vec2 { return null; }
    public function setColumn(i:Int, v:Vec2):Void {}

    // Element access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }

    // Operators
    @:op(A + B) static function add(a:Mat2, b:Mat2):Mat2 { return null; }
    @:op(A - B) static function sub(a:Mat2, b:Mat2):Mat2 { return null; }
    @:op(A * B) static function mul(a:Mat2, b:Mat2):Mat2 { return null; }
    @:op(A * B) static function mulVec(a:Mat2, b:Vec2):Vec2 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Mat2, b:Float):Mat2 { return null; }
    @:op(A / B) static function divScalar(a:Mat2, b:Float):Mat2 { return null; }
    @:op(-A) static function neg(a:Mat2):Mat2 { return null; }

    // Determinant
    public function determinant():Float { return 0.0; }

    // Transpose
    public function transpose():Mat2 { return null; }

    // Inverse
    public function inverse():Mat2 { return null; }
}
