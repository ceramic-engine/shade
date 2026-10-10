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
     * Output filename suffix of the current transpile variant. The instanced
     * variant (`-D shade_instanced`; shader sources opt in with
     * `#if shade_instanced` blocks and `@instance` vertex fields) appends
     * `_inst` so both variants of a shader coexist in the output folder.
     */
    public static function getOutputSuffix():String {
        return haxe.macro.Context.defined('shade_instanced') ? '_inst' : '';
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
     * Options of a shader class, from its `@shade({ ... })` metadata (see `classOptions()`).
     */
    public static final CLASS_OPTION_VALUES:Map<String, Array<String>> = [
        'mode' => ['2d', '3d'],
        'precision' => ['mediump', 'highp']
    ];

    static var classOptionsCache:Map<String, ShadeClassOptions> = new Map();

    /**
     * Read the `@shade({ mode: '2d' | '3d', precision: 'mediump' | 'highp' })` metadata of a
     * shader class, with defaults applied: `mode` is `'2d'`, and `precision` is `'highp'`
     * for a 3D class, `'mediump'` otherwise. Anything unexpected in the metadata, and the
     * former `@:shade3d` / `@:shadehighp` metadata, is a compilation error at its position.
     */
    public static function classOptions(classType:ClassType):ShadeClassOptions {
        final key = classType.pack.concat([classType.name]).join('.');
        final cached = classOptionsCache.get(key);
        if (cached != null) return cached;

        final meta = classType.meta;
        for (legacy => replacement in [':shade3d' => "@shade({ mode: '3d' })", ':shadehighp' => "@shade({ precision: 'highp' })"]) {
            if (meta.has(legacy)) {
                final entry = meta.extract(legacy)[0];
                haxe.macro.Context.error('@' + legacy + ' is not supported anymore, use ' + replacement, entry.pos);
            }
        }

        var mode:String = null;
        var precision:String = null;

        final entries = meta.extract('shade');
        if (entries.length > 1) {
            haxe.macro.Context.error('Only one @shade({ ... }) metadata is allowed per class', entries[1].pos);
        }
        if (entries.length == 1) {
            final entry = entries[0];
            if (entry.params == null || entry.params.length != 1) {
                haxe.macro.Context.error('@shade expects a single object literal: @shade({ mode: \'3d\', precision: \'highp\' })', entry.pos);
            }
            switch entry.params[0].expr {
                case EObjectDecl(fields):
                    for (field in fields) {
                        final allowed = CLASS_OPTION_VALUES.get(field.field);
                        if (allowed == null) {
                            haxe.macro.Context.error('Unknown @shade option "' + field.field + '", expected one of: ' + [for (k in CLASS_OPTION_VALUES.keys()) k].join(', '), field.expr.pos);
                        }
                        final value = switch field.expr.expr {
                            case EConst(CString(v, _)): v;
                            case _: null;
                        }
                        if (value == null || allowed.indexOf(value) == -1) {
                            haxe.macro.Context.error('@shade option "' + field.field + '" expects one of: ' + [for (v in allowed) "'" + v + "'"].join(', '), field.expr.pos);
                        }
                        switch field.field {
                            case 'mode': mode = value;
                            case 'precision': precision = value;
                            case _:
                        }
                    }
                case _:
                    haxe.macro.Context.error('@shade expects an object literal: @shade({ mode: \'3d\', precision: \'highp\' })', entry.params[0].pos);
            }
        }

        if (mode == null) mode = '2d';
        if (precision == null) precision = mode == '3d' ? 'highp' : 'mediump';

        final options:ShadeClassOptions = { mode: mode, precision: precision };
        classOptionsCache.set(key, options);
        return options;
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

    /**
     * Check if a type is SamplerCube.
     */
    public static function isSamplerCubeType(type:Type):Bool {
        return switch type {
            case TInst(t, _):
                t.get().name == 'SamplerCube';
            case TAbstract(t, _):
                t.get().name == 'SamplerCube';
            case _:
                false;
        }
    }

    /**
     * Check if a type is any sampler kind (Sampler2D or SamplerCube).
     */
    public static function isSamplerType(type:Type):Bool {
        return isSampler2DType(type) || isSamplerCubeType(type);
    }

    /**
     * Format a float literal (the `String` payload of `TConst(TFloat(s))`) for shader output.
     *
     * Ensures a trailing `.0` for integer-looking values (e.g. `"2"` -> `"2.0"`) so they keep
     * float type in GLSL/HLSL/PSSL, but leaves alone any literal that already has a decimal
     * point OR an exponent. Notably `"1e-9"` stays `"1e-9"` (a valid float literal in all three
     * targets) instead of becoming the invalid `"1e-9.0"`.
     */
    public static function formatFloatLiteral(s:String):String {
        if (s.indexOf('.') == -1 && s.indexOf('e') == -1 && s.indexOf('E') == -1) {
            return s + '.0';
        }
        return s;
    }

    /**
     * Returns true if `callee` is the static method of an abstract `@:op` operator overload
     * (e.g. Mat*Vec, Vec*Vec, vec*scalar, vec+scalar...). These are represented as
     * `TCall(TField(_, FStatic(c, cf)), args)` where the resolved static field carries `:op`.
     * Mirrors the detection used by each backend's `needsParenthesesForPrecedence`.
     */
    public static function isAbstractOpCall(callee:TypedExpr):Bool {
        switch callee.expr {
            case TField(_, fa):
                switch fa {
                    case FStatic(c, cf):
                        final fieldName = cf.get().name;
                        for (f in c.get().statics.get()) {
                            if (f.name == fieldName) {
                                return f.meta.has(':op');
                            }
                        }
                    case _:
                }
            case _:
        }
        return false;
    }

    /**
     * The binary operator `expr` prints as when it is emitted infix: a raw `TBinop`, or a
     * call to an abstract `@:op(A op B)` overload. `null` for anything else.
     */
    public static function infixBinop(expr:TypedExpr):Null<Binop> {
        return switch expr.expr {
            case TBinop(op, _, _): op;
            case TCall(callee, _): abstractOpBinop(callee);
            case _: null;
        }
    }

    /**
     * The binary operator of an abstract `@:op(A op B)` overload call, or `null` when
     * `callee` is not one (unary overloads included).
     */
    public static function abstractOpBinop(callee:TypedExpr):Null<Binop> {
        switch callee.expr {
            case TField(_, FStatic(c, cf)):
                final fieldName = cf.get().name;
                for (f in c.get().statics.get()) {
                    if (f.name == fieldName) {
                        for (meta in f.meta.get()) {
                            if (meta.name == ':op') {
                                switch meta.params[0].expr {
                                    case EBinop(op, _, _): return op;
                                    case _:
                                }
                            }
                        }
                        return null;
                    }
                }
            case _:
        }
        return null;
    }

    /**
     * Whether `expr`, printed as the left or right operand of `outerOp`, must be wrapped in
     * parentheses. Haxe drops the parentheses the source had around the arguments of abstract
     * operator calls, so they are rebuilt from precedence: a lower-precedence infix operand
     * always needs them, and on the right side an equal-precedence one does too
     * (`a - (b - c)`, `a / (b * c)`). Ternaries and casts are wrapped as well.
     */
    public static function operandNeedsParens(expr:TypedExpr, outerOp:Binop, right:Bool):Bool {
        final innerOp = infixBinop(expr);
        if (innerOp != null) {
            final inner = getOperatorPrecedence(innerOp);
            final outer = getOperatorPrecedence(outerOp);
            return inner < outer || (right && inner == outer);
        }
        return switch expr.expr {
            case TIf(_, _, _): true;
            case TCast(_, _): true;
            case _: false;
        }
    }

    /**
     * Whether `expr`, printed as the operand of a prefix unary operator, must be wrapped in
     * parentheses: infix expressions (`-(a - b)`), and unary ones (`-(-x)` must not print
     * as `--x`).
     */
    public static function unaryOperandNeedsParens(expr:TypedExpr):Bool {
        if (infixBinop(expr) != null) return true;
        return switch expr.expr {
            case TUnop(_, _, _): true;
            case TIf(_, _, _): true;
            case TCast(_, _): true;
            case TCall(callee, _): isAbstractOpCall(callee);
            case _: false;
        }
    }

    /**
     * Returns true if expression `e`, when used as the target of a field access / swizzle
     * (`e.field`), must be wrapped in parentheses so the field binds to the whole expression
     * rather than just its right operand, e.g. `(m * v).xyz`, not `m * v.xyz`.
     *
     * True for raw binops, unary ops, ternaries, casts, and abstract `@:op` operator calls
     * (operators are emitted infix). False for primary expressions and ordinary function calls
     * (`normalize(x).xyz` must stay unparenthesized).
     */
    public static function fieldTargetNeedsParens(e:TypedExpr):Bool {
        return switch e.expr {
            case TBinop(_, _, _): true;
            case TUnop(_, _, _): true;
            case TIf(_, _, _): true;
            case TCast(_, _): true;
            case TCall(callee, _): isAbstractOpCall(callee);
            case _: false;
        }
    }
}

/**
 * Options of a shader class, read from `@shade({ ... })` by `ShaderUtils.classOptions()`.
 */
typedef ShadeClassOptions = {
    /** `'2d'` or `'3d'` */
    final mode:String;
    /** `'mediump'` or `'highp'`, the GLSL ES float precision */
    final precision:String;
}

#end
