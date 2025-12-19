package shade.backend;

#if (macro || shade_compiler)

import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.output.OutputPath;
import shade.compiler.Backend;
import shade.compiler.Printer;
import shade.compiler.ShaderKind;
import shade.compiler.ShaderUtils;

using StringTools;

/**
 * GLSL shader backend.
 * Generates .vert and .frag files for OpenGL/WebGL.
 */
class GlslBackend implements Backend {
    public var id(default, null):String = "glsl";

    public function new() {}

    public function generate(
        classType:ClassType,
        varFields:Array<ClassVarData>,
        funcFields:Array<ClassFuncData>,
        setExtraFile:(filename:OutputPath, content:String) -> Void
    ):Void {
        final parent = classType.superClass?.t.get();
        if (parent == null) return;
        if (parent.pack == null || parent.pack.length != 1 || parent.pack[0] != 'shade') return;

        final shaderName = ShaderUtils.getQualifiedBaseName(classType.pack, classType.name);

        switch parent.name {
            case 'Vert':
                setExtraFile(shaderName + '.vert', compileVertexShader(classType, varFields, funcFields, 0));

                if (ShaderUtils.hasMultiAnnotation(varFields)) {
                    setExtraFile(shaderName + '_mt8.vert', compileVertexShader(classType, varFields, funcFields, 8));
                }

            case 'Frag':
                setExtraFile(shaderName + '.frag', compileFragmentShader(classType, varFields, funcFields, 0));

                if (ShaderUtils.hasMultiAnnotation(varFields)) {
                    setExtraFile(shaderName + '_mt8.frag', compileFragmentShader(classType, varFields, funcFields, 8));
                }

            case _:
        }
    }

    function compileVertexShader(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>, multi:Int = 0):String {
        final printer = new Printer();

        // Resolve context
        final ctx:GlslContext = {
            multi: multi,
            shaderKind: VERT
        };

        // Header
        printer.writeln("#version 300 es");
        printer.line();

        // Uniforms
        var numUniforms = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.meta.has('param')) {
                numUniforms++;
                printer.write("uniform ");
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numUniforms > 0) {
            printer.line();
        }

        // Attributes (in)
        var numIns = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.meta.has('in') && (!field.meta.has('multi') || ctx.multi > 0)) {
                numIns++;
                printer.write("in ");
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numIns > 0) {
            printer.line();
        }

        // Attributes (out)
        var numOuts = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.meta.has('out') && (!field.meta.has('multi') || ctx.multi > 0)) {
                numOuts++;
                printer.write("out ");
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numOuts > 0) {
            printer.line();
        }

        // Class-level variables (globals in GLSL)
        var numGlobals = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.name != '__meta__' && !field.meta.has('in') && !field.meta.has('out') && !field.meta.has('param')) {
                numGlobals++;
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numGlobals > 0) {
            printer.line();
        }

        // Functions
        for (funcField in funcFields) {
            final field = funcField.field;
            if (field.name == 'main') {
                printer.writeln("void main(void) {");
                printer.indent();
                ctx.inMain = true;
                switch funcField.expr.expr {
                    case TBlock(el):
                        for (expr in el) {
                            switch expr.expr {
                                case TReturn(e):
                                    printer.write('gl_Position = ');
                                    printExpression(printer, e, ctx);
                                    if (!printer.endsBlock()) {
                                        printer.endBlock(';');
                                        printer.line();
                                    }
                                case _:
                                    printExpression(printer, expr, ctx);
                                    if (!printer.endsBlock()) {
                                        printer.endBlock(';');
                                        printer.line();
                                    }
                            }
                        }
                    case TReturn(e):
                        printer.write('gl_Position = ');
                        printExpression(printer, e, ctx);
                        if (!printer.endsBlock()) {
                            printer.endBlock(';');
                            printer.line();
                        }
                    case _:
                }
                ctx.inMain = false;
                printer.writeln('gl_PointSize = 1.0;');
                printer.unindent();
                printer.writeln("}");
            } else if (field.name != 'new') {
                switch field.type {
                    case TFun(args, ret):
                        printer.write(compileGlslType(ret));
                        printer.write(' ');
                        printer.write(field.name);
                        printer.write('(');
                        if (args.length == 0) {
                            printer.write(', ');
                        } else {
                            for (i in 0...args.length) {
                                if (i > 0) {
                                    printer.write(', ');
                                }
                                final arg = args[i];
                                printer.write(compileGlslType(arg.t));
                                printer.write(' ');
                                printer.write(arg.name);
                            }
                        }
                        printer.write(') ');
                        printExpression(printer, ShaderUtils.ensureBlock(funcField.expr), ctx);
                        printer.line();
                    case _:
                }
            }
        }

        return printer.toString();
    }

    function compileFragmentShader(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>, multi:Int = 0):String {
        final printer = new Printer();

        // Resolve context
        final ctx:GlslContext = {
            multi: multi,
            shaderKind: FRAG
        };
        if (multi > 0) {
            for (varField in varFields) {
                final field = varField.field;
                if (field.meta.has('multi')) {
                    if (field.meta.has('in')) {
                        ctx.multiSlotField = field.name;
                    } else if (field.meta.has('param')) {
                        ctx.multiTextureField = field.name;
                    }
                }
            }
        }

        // Header
        printer.writeln("#version 300 es");
        printer.line();

        // Precision
        printer.writeln('#ifdef GL_ES');
        printer.writeln('precision mediump float;');
        printer.writeln('#else');
        printer.writeln('#define mediump');
        printer.writeln('#endif');
        printer.line();

        // Uniforms
        var numUniforms = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.meta.has('param')) {
                numUniforms++;
                if (field.meta.has('multi')) {
                    if (ctx.multi > 0) {
                        for (i in 0...ctx.multi) {
                            printer.write("uniform ");
                            printer.write(compileGlslType(field.type));
                            printer.write(" ");
                            if (field.name == "mainTex") {
                                if (i == 0) {
                                    printer.write("mainTex");
                                } else {
                                    printer.write("tex" + i);
                                }
                            } else {
                                printer.write(field.name + '_' + i);
                            }
                            printer.write(";");
                            printer.line();
                        }
                    } else {
                        printer.write("uniform ");
                        printer.write(compileGlslType(field.type));
                        printer.write(" ");
                        printer.write(field.name);
                        printer.write(";");
                        printer.line();
                    }
                } else {
                    printer.write("uniform ");
                    printer.write(compileGlslType(field.type));
                    printer.write(" ");
                    printer.write(field.name);
                    printer.write(";");
                    printer.line();
                }
            }
        }
        if (numUniforms > 0) {
            printer.line();
        }

        // Attributes (in)
        var numIns = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.meta.has('in') && (!field.meta.has('multi') || ctx.multi > 0)) {
                numIns++;
                printer.write("in ");
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numIns > 0) {
            printer.line();
        }

        printer.writeln('out vec4 fragColor;');
        printer.line();

        // Class-level variables (globals in GLSL)
        var numGlobals = 0;
        for (varField in varFields) {
            final field = varField.field;
            if (field.name != '__meta__' && !field.meta.has('in') && !field.meta.has('out') && !field.meta.has('param')) {
                numGlobals++;
                printer.write(compileGlslType(field.type));
                printer.write(" ");
                printer.write(field.name);
                printer.write(";");
                printer.line();
            }
        }
        if (numGlobals > 0) {
            printer.line();
        }

        // Main
        for (funcField in funcFields) {
            final field = funcField.field;
            if (field.name == 'main') {
                printer.writeln("void main(void) {");
                printer.indent();
                ctx.inMain = true;
                switch funcField.expr.expr {
                    case TBlock(el):
                        for (expr in el) {
                            switch expr.expr {
                                case TReturn(e):
                                    printer.write('fragColor = ');
                                    printExpression(printer, e, ctx);
                                    if (!printer.endsBlock()) {
                                        printer.endBlock(';');
                                        printer.line();
                                    }
                                case _:
                                    printExpression(printer, expr, ctx);
                                    if (!printer.endsBlock()) {
                                        printer.endBlock(';');
                                        printer.line();
                                    }
                            }
                        }
                    case TReturn(e):
                        printer.write('fragColor = ');
                        printExpression(printer, e, ctx);
                        if (!printer.endsBlock()) {
                            printer.endBlock(';');
                            printer.line();
                        }
                    case _:
                }
                ctx.inMain = false;
                printer.unindent();
                printer.endBlock('}');
                printer.line();
                printer.line();
            } else if (field.name != 'new') {
                switch field.type {
                    case TFun(args, ret):
                        printer.write(compileGlslType(ret));
                        printer.write(' ');
                        printer.write(field.name);
                        printer.write('(');
                        for (i in 0...args.length) {
                            if (i > 0) {
                                printer.write(', ');
                            }
                            final arg = args[i];
                            printer.write(compileGlslType(arg.t));
                            printer.write(' ');
                            printer.write(arg.name);
                        }
                        printer.write(') ');
                        printExpression(printer, ShaderUtils.ensureBlock(funcField.expr), ctx);
                        printer.line();
                    case _:
                }
            }
        }

        return printer.toString();
    }

    function printExpression(printer:Printer, expr:TypedExpr, ctx:GlslContext):Void {

        switch expr.expr {
            case TConst(c):
                switch c {
                    case TInt(i):
                        printer.write(Std.string(i));
                    case TFloat(s):
                        final str = Std.string(s);
                        printer.write(str);
                        if (str.indexOf('.') == -1) {
                            printer.write('.0');
                        }
                    case TString(s):
                    case TBool(b):
                        if (b) {
                            printer.write('true');
                        } else {
                            printer.write('false');
                        }
                    case TNull:
                    case TThis:
                    case TSuper:
                }
            case TLocal(v):
                printer.write(v.name);
            case TArray(e1, e2):
            case TBinop(op, e1, e2):
                printExpression(printer, e1, ctx);
                switch op {
                    case OpAdd:
                        printer.write(' + ');
                    case OpMult:
                        printer.write(' * ');
                    case OpDiv:
                        printer.write(' / ');
                    case OpSub:
                        printer.write(' - ');
                    case OpAssign:
                        printer.write(' = ');
                    case OpEq:
                        printer.write(' == ');
                    case OpNotEq:
                        printer.write(' != ');
                    case OpGt:
                        printer.write(' > ');
                    case OpGte:
                        printer.write(' >= ');
                    case OpLt:
                        printer.write(' < ');
                    case OpLte:
                        printer.write(' <= ');
                    case OpAnd:
                        printer.write(' & ');
                    case OpOr:
                        printer.write(' | ');
                    case OpBoolAnd:
                        printer.write(' && ');
                    case OpBoolOr:
                        printer.write(' || ');
                    case OpMod:
                        printer.write(' % ');
                    case OpAssignOp(subOp):
                        switch subOp {
                            case OpAdd:
                                printer.write(' += ');
                            case OpMult:
                                printer.write(' *= ');
                            case OpDiv:
                                printer.write(' /= ');
                            case OpSub:
                                printer.write(' -= ');
                            case OpMod:
                                printer.write(' %= ');
                            case _:
                        }
                    case OpXor | OpShl | OpShr | OpUShr | OpInterval | OpArrow | OpIn | OpNullCoal:
                }
                printExpression(printer, e2, ctx);
            case TField(e, fa):
                switch e.expr {
                    case TConst(TThis):
                    case _:
                        printExpression(printer, e, ctx);
                        printer.write('.');
                }
                switch fa {
                    case FInstance(c, params, cf):
                        final name = cf.get().name;
                        if (ctx.multiTextureField == name) {
                            if (name == "mainTex") {
                                if (ctx.multiCurrentSlot == 0) {
                                    printer.write("mainTex");
                                } else {
                                    printer.write("tex" + ctx.multiCurrentSlot);
                                }
                            } else {
                                printer.write(name + '_' + ctx.multiCurrentSlot);
                            }
                        } else {
                            printer.write(name);
                        }
                    case FStatic(c, cf):
                    case FAnon(cf):
                    case FDynamic(s):
                    case FClosure(c, cf):
                    case FEnum(e, ef):
                }
            case TTypeExpr(m):
            case TParenthesis(e):
                printer.write('(');
                printExpression(printer, e, ctx);
                printer.write(')');
            case TObjectDecl(fields):
            case TArrayDecl(el):
            case TCall(e, el):
                switch e.expr {
                    case TField(ee, fa):

                        // Detect shade Functions (helpers) calls
                        switch ee.t {
                            case TType(t, params):
                                final defType = t.get();
                                if (defType.module == 'shade.Functions') {
                                    switch fa {
                                        case FStatic(c, cf):
                                            printer.write(cf.get().name);
                                        case _:
                                    }
                                    printer.write('(');
                                    for (i in 0...el.length) {
                                        if (i > 0) {
                                            printer.write(', ');
                                        }
                                        printExpression(printer, el[i], ctx);
                                    }
                                    printer.write(')');
                                    return;
                                }
                            case _:
                        }

                        switch fa {
                            case FStatic(c, cf):
                                var resolvedField = null;
                                final fieldName = cf.get().name;
                                for (f in c.get().statics.get()) {
                                    if (f.name == fieldName) {
                                        resolvedField = f;
                                        break;
                                    }
                                }

                                // Detect abstracts operator overloads
                                if (resolvedField != null && resolvedField.meta.has(':op')) {
                                    for (meta in resolvedField.meta.get()) {
                                        if (meta.name == ':op') {
                                            printAbstractOp(printer, meta, el, ctx);
                                            return;
                                        }
                                    }
                                }

                                // Detect abstract getters
                                if (fieldName.startsWith('get_')) {
                                    final propName = fieldName.substr(4);
                                    printExpression(printer, el[0], ctx);
                                    printer.write('.');
                                    printer.write(propName);
                                    return;
                                }

                                // Detect abstract setters
                                if (fieldName.startsWith('set_')) {
                                    final propName = fieldName.substr(4);
                                    printExpression(printer, el[0], ctx);
                                    printer.write('.');
                                    printer.write(propName);
                                    printer.write(' = ');
                                    printExpression(printer, el[1], ctx);
                                    return;
                                }
                            case _:
                        }
                    case _:
                }

                // Regular call
                printExpression(printer, e, ctx);
                printer.write('(');
                for (i in 0...el.length) {
                    if (i > 0) {
                        printer.write(', ');
                    }
                    printExpression(printer, el[i], ctx);
                }
                printer.write(')');

            case TNew(c, params, el):
            case TUnop(op, postFix, e):
                if (postFix) {
                    printExpression(printer, e, ctx);
                }
                switch op {
                    case OpIncrement:
                        printer.write('++');
                    case OpDecrement:
                        printer.write('--');
                    case OpNot:
                        printer.write('!');
                    case OpNeg:
                        printer.write('-');
                    case OpNegBits:
                        printer.write('~');
                    case OpSpread:
                        printer.write('...');
                }
                if (!postFix) {
                    printExpression(printer, e, ctx);
                }
            case TFunction(tfunc):
            case TVar(v, expr):
                printer.write(compileGlslType(v.t));
                printer.write(' ');
                printer.write(v.name);
                if (expr != null) {
                    printer.write(' = ');
                    printExpression(printer, expr, ctx);
                }
            case TBlock(el):
                printer.writeln('{');
                printer.indent();
                for (expr in el) {
                    printExpression(printer, expr, ctx);
                    if (!printer.endsBlock()) {
                        printer.endBlock(';');
                        printer.line();
                    }
                }
                printer.unindent();
                printer.endBlock('}');
                printer.line();
            case TFor(v, e1, e2):
            case TIf(econd, eif, eelse):
                printer.write('if ');
                printExpression(printer, ShaderUtils.ensureParenthesis(econd), ctx);
                printer.write(' ');
                printExpression(printer, ShaderUtils.ensureBlock(eif), ctx);
                if (eelse != null) {
                    switch eelse.expr {
                        case TIf(_, _, _):
                            printer.write('else ');
                            printExpression(printer, eelse, ctx);
                        case _:
                            printer.write('else ');
                            printExpression(printer, ShaderUtils.ensureBlock(eelse), ctx);
                    }
                }
            case TWhile(econd, e, normalWhile):
                if (normalWhile) {
                    printer.write('while ');
                    printExpression(printer, ShaderUtils.ensureParenthesis(econd), ctx);
                    printer.write(' ');
                    printExpression(printer, ShaderUtils.ensureBlock(e), ctx);
                } else {
                    printer.write('do ');
                    printExpression(printer, ShaderUtils.ensureBlock(e), ctx);
                    printer.write('while ');
                    printExpression(printer, ShaderUtils.ensureParenthesis(econd), ctx);
                }
            case TSwitch(e, cases, edef):
            case TTry(e, catches):
            case TReturn(e):
                if (ctx.inMain) {
                    if (ctx.shaderKind == VERT) {
                        printer.write('gl_Position = ');
                    } else {
                        printer.write('fragColor = ');
                    }
                    printExpression(printer, e, ctx);
                } else {
                    printer.write('return ');
                    printExpression(printer, e, ctx);
                }
            case TBreak:
            case TContinue:
            case TThrow(e):
            case TCast(e, m):
            case TMeta(m, e1):
                if (m.name == 'multi') {
                    if (ctx.shaderKind == FRAG && ctx.multi > 0) {
                        if (ctx.multiSlotField != null) {
                            for (i in 0...ctx.multi) {
                                if (i > 0) {
                                    printer.write('else ');
                                }
                                printer.write('if (');
                                printer.write(ctx.multiSlotField);
                                printer.writeln(' == ${i}.0) {');
                                printer.indent();
                                ctx.multiCurrentSlot = i;
                                switch e1.expr {
                                    case TBlock(el):
                                        for (expr in el) {
                                            printExpression(printer, expr, ctx);
                                            if (!printer.endsBlock())
                                                printer.endBlock(';');
                                            printer.line();
                                        }
                                    case _:
                                        printExpression(printer, e1, ctx);
                                        if (!printer.endsBlock())
                                            printer.endBlock(';');
                                        printer.line();
                                }
                                ctx.multiCurrentSlot = -1;
                                printer.unindent();
                                printer.endBlock('}');
                                printer.line();
                            }
                        }
                    } else if (ctx.shaderKind == FRAG || (ctx.shaderKind == VERT && ctx.multi > 0)) {
                        printExpression(printer, e1, ctx);
                    }
                } else {
                    printExpression(printer, e1, ctx);
                }
            case TEnumParameter(e1, ef, index):
            case TEnumIndex(e1):
            case TIdent(s):
        }
    }

    function printAbstractOp(printer:Printer, meta:MetadataEntry, el:Array<TypedExpr>, ctx:GlslContext):Void {
        switch meta.params[0].expr {
            case EBinop(op, e1, e2):
                // Check if left operand needs parentheses due to lower precedence
                final needsParensLeft = needsParenthesesForPrecedence(el[0], op);
                if (needsParensLeft)
                    printer.write('(');
                printExpression(printer, el[0], ctx);
                if (needsParensLeft)
                    printer.write(')');
                switch op {
                    case OpAdd:
                        printer.write(' + ');
                    case OpMult:
                        printer.write(' * ');
                    case OpDiv:
                        printer.write(' / ');
                    case OpSub:
                        printer.write(' - ');
                    case OpAssign:
                        printer.write(' = ');
                    case OpEq:
                        printer.write(' == ');
                    case OpNotEq:
                        printer.write(' != ');
                    case OpGt:
                        printer.write(' > ');
                    case OpGte:
                        printer.write(' >= ');
                    case OpLt:
                        printer.write(' < ');
                    case OpLte:
                        printer.write(' <= ');
                    case OpAnd:
                        printer.write(' && ');
                    case OpOr:
                        printer.write(' || ');
                    case OpAssignOp(subOp):
                        switch subOp {
                            case OpAdd:
                                printer.write(' += ');
                            case OpMult:
                                printer.write(' *= ');
                            case OpDiv:
                                printer.write(' /= ');
                            case OpSub:
                                printer.write(' -= ');
                            case _:
                        }
                    case OpXor | OpBoolAnd | OpBoolOr | OpShl | OpShr | OpUShr | OpMod | OpInterval | OpArrow | OpIn | OpNullCoal:
                }
                // Check if right operand needs parentheses due to lower precedence
                final needsParensRight = needsParenthesesForPrecedence(el[1], op);
                if (needsParensRight)
                    printer.write('(');
                printExpression(printer, el[1], ctx);
                if (needsParensRight)
                    printer.write(')');
            case EUnop(op, postFix, e):
                if (postFix) {
                    printExpression(printer, el[0], ctx);
                }
                switch op {
                    case OpIncrement:
                        printer.write('++');
                    case OpDecrement:
                        printer.write('--');
                    case OpNot:
                        printer.write('!');
                    case OpNeg:
                        printer.write('-');
                    case OpNegBits:
                        printer.write('~');
                    case OpSpread:
                        printer.write('...');
                }
                if (!postFix) {
                    printExpression(printer, el[0], ctx);
                }
            case _:
        }
    }

    /** Check if an expression needs parentheses when used as operand of outerOp */
    function needsParenthesesForPrecedence(expr:TypedExpr, outerOp:Binop):Bool {
        // Check if the expression is itself an abstract operator call with lower precedence
        switch expr.expr {
            case TCall(e, el):
                switch e.expr {
                    case TField(_, fa):
                        switch fa {
                            case FStatic(c, cf):
                                final fieldName = cf.get().name;
                                var resolvedField = null;
                                for (f in c.get().statics.get()) {
                                    if (f.name == fieldName) {
                                        resolvedField = f;
                                        break;
                                    }
                                }
                                if (resolvedField != null && resolvedField.meta.has(':op')) {
                                    for (meta in resolvedField.meta.get()) {
                                        if (meta.name == ':op') {
                                            switch meta.params[0].expr {
                                                case EBinop(innerOp, _, _):
                                                    // Need parens if inner op has lower precedence than outer
                                                    return ShaderUtils.getOperatorPrecedence(innerOp) < ShaderUtils.getOperatorPrecedence(outerOp);
                                                case _:
                                            }
                                        }
                                    }
                                }
                            case _:
                        }
                    case _:
                }
            case _:
        }
        return false;
    }

    function compileGlslType(type:Type):String {
        return switch type {
            case TInst(t, params):
                final name = t.get().name;
                name.charAt(0).toLowerCase() + name.substr(1);
            case TAbstract(t, params):
                final name = t.get().name;
                name.charAt(0).toLowerCase() + name.substr(1);
            case _:
                null;
        }
    }
}

@:structInit
class GlslContext {
    public var multi:Int;
    public var shaderKind:ShaderKind;
    public var inMain:Bool = false;
    public var multiSlotField:String = null;
    public var multiTextureField:String = null;
    public var multiCurrentSlot:Int = -1;
}

#end
