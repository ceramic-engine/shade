package shade;

extern class IMat3 {}

abstract Mat3(IMat3) {
    // Column-major storage
    public function new(
        m00:Float = 1, m10:Float = 0, m20:Float = 0,
        m01:Float = 0, m11:Float = 1, m21:Float = 0,
        m02:Float = 0, m12:Float = 0, m22:Float = 1
    ) {
        this = null;
    }

    // Create identity matrix
    public static function identity():Mat3 { return null; }

    // Create from diagonal value
    public static function fromDiagonal(v:Float):Mat3 { return null; }

    // Create from column vectors
    public static function fromColumns(col0:Vec3, col1:Vec3, col2:Vec3):Mat3 { return null; }

    // Extract from Mat4 (upper-left 3x3)
    public static function fromMat4(m:Mat4):Mat3 { return null; }

    // Column access
    public function getColumn(i:Int):Vec3 { return null; }
    public function setColumn(i:Int, v:Vec3):Void {}

    // Element access
    @:op([]) function arrayGet(i:Int):Float { return 0.0; }
    @:op([]) function arraySet(i:Int, v:Float):Float { return v; }

    // Operators
    @:op(A + B) static function add(a:Mat3, b:Mat3):Mat3 { return null; }
    @:op(A - B) static function sub(a:Mat3, b:Mat3):Mat3 { return null; }
    @:op(A * B) static function mul(a:Mat3, b:Mat3):Mat3 { return null; }
    @:op(A * B) static function mulVec(a:Mat3, b:Vec3):Vec3 { return null; }
    @:op(A * B) @:commutative static function mulScalar(a:Mat3, b:Float):Mat3 { return null; }
    @:op(-A) static function neg(a:Mat3):Mat3 { return null; }

    // Determinant
    public function determinant():Float { return 0.0; }

    // Transpose
    public function transpose():Mat3 { return null; }
}
