package shade.compiler;

#if (macro || shade_compiler)

import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.data.ClassVarData;

using StringTools;

/**
 * Shared utilities for shader backends.
 */
class ShaderUtils {

    /**
     * Get the base shader name by stripping _Vert or _Frag suffix.
     * Also lowercases the first character.
     */
    public static function getBaseName(className:String):String {
        final lastUnderscore = className.lastIndexOf('_');
        if (lastUnderscore > 0) {
            final suffix = className.substring(lastUnderscore);
            if (suffix == '_Vert' || suffix == '_Frag') {
                final baseName = className.substring(0, lastUnderscore);
                return baseName.charAt(0).toLowerCase() + baseName.substring(1);
            }
        }
        return className.charAt(0).toLowerCase() + className.substring(1);
    }

    /**
     * Get the qualified base shader name including package path.
     * Enables multiple shaders with the same class name in different packages.
     * Example: package ['shaders', 'effects'] + class 'Blur_Vert' → 'shaders_effects_blur'
     */
    public static function getQualifiedBaseName(pack:Array<String>, className:String):String {
        final baseName = getBaseName(className);
        if (pack == null || pack.length == 0) {
            return baseName;
        }
        return pack.join('_') + '_' + baseName;
    }

    /**
     * Check if a class name represents a vertex shader.
     */
    public static function isVertexShader(className:String):Bool {
        return className.endsWith('_Vert');
    }

    /**
     * Check if a class name represents a fragment shader.
     */
    public static function isFragmentShader(className:String):Bool {
        return className.endsWith('_Frag');
    }

    /**
     * Check if the shader uses multi-texture feature.
     */
    public static function hasMultiAnnotation(varFields:Array<ClassVarData>):Bool {
        for (varField in varFields) {
            if (varField.field.meta.has('multi')) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns operator precedence (higher number = higher precedence).
     */
    public static function getOperatorPrecedence(op:Binop):Int {
        return switch op {
            case OpMult | OpDiv | OpMod: 5;
            case OpAdd | OpSub: 4;
            case OpShl | OpShr | OpUShr: 3;
            case OpLt | OpLte | OpGt | OpGte: 2;
            case OpEq | OpNotEq: 1;
            case OpAnd: 0;
            case OpXor: -1;
            case OpOr: -2;
            case OpBoolAnd: -3;
            case OpBoolOr: -4;
            case _: -10;
        }
    }

    /**
     * Ensure expression is wrapped in parentheses.
     */
    public static function ensureParenthesis(expr:TypedExpr):TypedExpr {
        return switch expr.expr {
            case TParenthesis(e): expr;
            case _: {
                    expr: TParenthesis(expr),
                    pos: expr.pos,
                    t: expr.t
                }
        }
    }

    /**
     * Ensure expression is wrapped in a block.
     */
    public static function ensureBlock(expr:TypedExpr):TypedExpr {
        return switch expr.expr {
            case TBlock(el): expr;
            case _: {
                    expr: TBlock([expr]),
                    pos: expr.pos,
                    t: expr.t
                }
        }
    }

    /**
     * Check if a type is a matrix type (mat2, mat3, mat4, etc.)
     */
    public static function isMatrixType(type:Type):Bool {
        return switch type {
            case TInst(t, params):
                final name = t.get().name;
                name == 'Mat2' || name == 'Mat3' || name == 'Mat4';
            case TAbstract(t, params):
                final name = t.get().name;
                name == 'Mat2' || name == 'Mat3' || name == 'Mat4';
            case _:
                false;
        }
    }

    /**
     * Check if a type is Mat2.
     */
    public static function isMat2Type(type:Type):Bool {
        return switch type {
            case TInst(t, params):
                t.get().name == 'Mat2';
            case TAbstract(t, params):
                t.get().name == 'Mat2';
            case _:
                false;
        }
    }

    /**
     * Check if a type is Mat3.
     */
    public static function isMat3Type(type:Type):Bool {
        return switch type {
            case TInst(t, params):
                t.get().name == 'Mat3';
            case TAbstract(t, params):
                t.get().name == 'Mat3';
            case _:
                false;
        }
    }

    /**
     * Check if a type is Sampler2D.
     */
    public static function isSampler2DType(type:Type):Bool {
        return switch type {
            case TInst(t, _):
                t.get().name == 'Sampler2D';
            case TAbstract(t, _):
                t.get().name == 'Sampler2D';
            case _:
                false;
        }
    }
}

#end
