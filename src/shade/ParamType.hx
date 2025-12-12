package shade;

enum abstract ParamType(Int) {

    var Float;

    var Vec2;

    var Vec3;

    var Vec4;

    var Mat2;

    var Mat3;

    var Mat4;

    var Sampler2D;

    /**
     * Returns a string representation of this enum value.
     */
    public function toString() {
        return switch abstract {
            case Float: 'Float';
            case Vec2: 'Vec2';
            case Vec3: 'Vec3';
            case Vec4: 'Vec4';
            case Mat2: 'Mat2';
            case Mat3: 'Mat3';
            case Mat4: 'Mat4';
            case Sampler2D: 'Sampler2D';
        }
    }

    public static function fromString(str:String):Null<ParamType> {
        return switch (str) {
            case 'Float': Float;
            case 'Vec2': Vec2;
            case 'Vec3': Vec3;
            case 'Vec4': Vec4;
            case 'Mat2': Mat2;
            case 'Mat3': Mat3;
            case 'Mat4': Mat4;
            case 'Sampler2D': Sampler2D;
            default: null;
        }
    }

}
