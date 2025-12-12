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
 * Unity shader backend.
 * Generates .shader files for Unity (HLSL/Cg).
 */
class UnityBackend implements Backend {
    public var id(default, null):String = "unity";

    // Buffer for pairing Vert/Frag classes
    var pendingVert:Map<String, ShaderClassData> = new Map();
    var pendingFrag:Map<String, ShaderClassData> = new Map();

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

        final baseName = ShaderUtils.getBaseName(classType.name);
        final isVert = ShaderUtils.isVertexShader(classType.name);
        final isFrag = ShaderUtils.isFragmentShader(classType.name);

        final thisData:ShaderClassData = {
            classType: classType,
            varFields: varFields,
            funcFields: funcFields
        };

        if (isVert) {
            if (pendingFrag.exists(baseName)) {
                // Pair found - generate shader
                final fragData = pendingFrag.get(baseName);
                generateUnityShader(baseName, thisData, fragData, setExtraFile);
                pendingFrag.remove(baseName);
            } else {
                // Buffer and wait
                pendingVert.set(baseName, thisData);
            }
        } else if (isFrag) {
            if (pendingVert.exists(baseName)) {
                // Pair found - generate shader
                final vertData = pendingVert.get(baseName);
                generateUnityShader(baseName, vertData, thisData, setExtraFile);
                pendingVert.remove(baseName);
            } else {
                // Buffer and wait
                pendingFrag.set(baseName, thisData);
            }
        }
    }

    function generateUnityShader(
        baseName:String,
        vertData:ShaderClassData,
        fragData:ShaderClassData,
        setExtraFile:(filename:OutputPath, content:String) -> Void
    ):Void {
        // Generate base shader
        setExtraFile(baseName + '.shader', compileUnityShader(baseName, vertData, fragData, 0));

        // Check if multi-texture variant needed
        if (ShaderUtils.hasMultiAnnotation(vertData.varFields) || ShaderUtils.hasMultiAnnotation(fragData.varFields)) {
            setExtraFile(baseName + '_mt8.shader', compileUnityShader(baseName + '_mt8', vertData, fragData, 8));
        }
    }

    function compileUnityShader(shaderName:String, vertData:ShaderClassData, fragData:ShaderClassData, multi:Int):String {
        final printer = new Printer('\t');

        // Create context to track helper function usage
        final ctx:UnityContext = {
            multi: multi,
            multiShader: FRAG
        };

        // Detect standard @in fields from vertex shader (first 3 non-multi @in fields: position, tcoord, color)
        var inFieldIndex = 0;
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('in') && !field.meta.has('multi')) {
                switch inFieldIndex {
                    case 0: ctx.inPosition = field.name;
                    case 1: ctx.inTCoord = field.name;
                    case 2: ctx.inColor = field.name;
                }
                inFieldIndex++;
                if (inFieldIndex >= 3) break;
            }
        }

        // Detect standard @out fields from vertex shader (first 2 non-multi @out fields: tcoord, color)
        var outFieldIndex = 0;
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('out') && !field.meta.has('multi')) {
                switch outFieldIndex {
                    case 0: ctx.outTCoord = field.name;
                    case 1: ctx.outColor = field.name;
                }
                outFieldIndex++;
                if (outFieldIndex >= 2) break;
            }
        }

        // Find the @in @multi field in vertex shader (e.g., vertexTextureId)
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('in') && field.meta.has('multi')) {
                ctx.vertexInputMultiField = field.name;
                break;
            }
        }

        // Find the @out @multi field in vertex shader (e.g., textureId)
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('out') && field.meta.has('multi')) {
                ctx.outMultiSlot = field.name;
                break;
            }
        }

        // Find the main texture field (first @param Sampler2D) and multi-texture fields
        for (varField in fragData.varFields) {
            final field = varField.field;
            if (field.meta.has('param') && ShaderUtils.isSampler2DType(field.type)) {
                // In non-multi mode, the first Sampler2D (even with @multi) is the main texture
                // In multi mode, the first Sampler2D without @multi is the main texture
                if (ctx.mainTextureField == null) {
                    if (multi == 0 || !field.meta.has('multi')) {
                        ctx.mainTextureField = field.name;
                    }
                }
                if (multi > 0 && field.meta.has('multi')) {
                    ctx.multiTextureField = field.name;
                }
            }
            if (multi > 0 && field.meta.has('multi') && field.meta.has('in')) {
                ctx.multiSlotField = field.name;
            }
        }

        // Shader header
        printer.writeln('Shader "$shaderName"');
        printer.writeln('{');
        printer.indent();

        // Properties block
        writePropertiesBlock(printer, vertData, fragData, multi);

        // SubShader block
        printer.writeln('SubShader');
        printer.writeln('{');
        printer.indent();

        // Tags
        printer.writeln('Tags');
        printer.writeln('{');
        printer.indent();
        printer.writeln('"Queue"="Transparent"');
        printer.writeln('"IgnoreProjector"="True"');
        printer.writeln('"RenderType"="Transparent"');
        printer.writeln('"PreviewType"="Plane"');
        printer.writeln('"CanUseSpriteAtlas"="True"');
        printer.unindent();
        printer.writeln('}');
        printer.line();

        // Render state
        printer.writeln('Cull Off');
        printer.writeln('Lighting Off');
        printer.writeln('ZWrite Off');
        printer.writeln('Blend [_SrcBlendRgb] [_DstBlendRgb], [_SrcBlendAlpha] [_DstBlendAlpha]');
        printer.line();

        printer.writeln('Stencil {');
        printer.indent();
        printer.writeln('Ref 1');
        printer.writeln('Comp [_StencilComp]');
        printer.unindent();
        printer.writeln('}');
        printer.line();

        // Pass block
        printer.writeln('Pass');
        printer.writeln('{');
        printer.writeln('CGPROGRAM');
        printer.indent();

        printer.writeln('#pragma vertex vert');
        printer.writeln('#pragma fragment frag');
        printer.writeln('#include "UnityCG.cginc"');
        printer.line();

        // Placeholder for helper functions (replaced at end if needed)
        printer.writeln('{{SHADE_HELPERS}}');

        // Structs
        writeAppdataStruct(printer, vertData, ctx);
        printer.line();
        writeV2fStruct(printer, vertData, ctx);
        printer.line();

        // Vertex helper functions (prefixed with vert_)
        writeHelperFunctions(printer, vertData.funcFields, ctx, 'vert_');

        // Vertex function
        writeVertexFunction(printer, vertData, ctx);
        printer.line();

        // Uniforms (samplers and other uniforms for fragment)
        writeFragmentUniforms(printer, fragData, ctx);
        printer.line();

        // Fragment helper functions (prefixed with frag_)
        writeHelperFunctions(printer, fragData.funcFields, ctx, 'frag_');

        // Reset context for fragment shader
        ctx.multiShader = FRAG;

        // Fragment function
        writeFragmentFunction(printer, fragData, ctx);

        printer.unindent();
        printer.writeln('ENDCG');
        printer.writeln('}');

        printer.unindent();
        printer.writeln('}');

        printer.unindent();
        printer.writeln('}');

        // Replace helper placeholder with actual helpers or remove it
        var result = printer.toString();
        final helperPrinter = new Printer('\t');
        helperPrinter.setIndent(3);

        if (ctx.needsShadeTextureHelper) {
            helperPrinter.line('// Unity texture sampling with Y-flip for GLSL-style compatibility');
            helperPrinter.writeln('float4 shade_texture(sampler2D tex, float2 uv) {');
            helperPrinter.indent();
            helperPrinter.writeln('return tex2D(tex, float2(uv.x, 1.0 - uv.y));');
            helperPrinter.unindent();
            helperPrinter.writeln('}');
            helperPrinter.line();
        }
        if (ctx.needsShadeModHelper) {
            helperPrinter.line('// GLSL-style mod (floor-based, not truncate-based like fmod)');
            helperPrinter.writeln('float shade_mod(float x, float y) {');
            helperPrinter.indent();
            helperPrinter.writeln('return x - y * floor(x / y);');
            helperPrinter.unindent();
            helperPrinter.writeln('}');
            helperPrinter.writeln('float2 shade_mod(float2 x, float2 y) {');
            helperPrinter.indent();
            helperPrinter.writeln('return x - y * floor(x / y);');
            helperPrinter.unindent();
            helperPrinter.writeln('}');
            helperPrinter.writeln('float3 shade_mod(float3 x, float3 y) {');
            helperPrinter.indent();
            helperPrinter.writeln('return x - y * floor(x / y);');
            helperPrinter.unindent();
            helperPrinter.writeln('}');
            helperPrinter.writeln('float4 shade_mod(float4 x, float4 y) {');
            helperPrinter.indent();
            helperPrinter.writeln('return x - y * floor(x / y);');
            helperPrinter.unindent();
            helperPrinter.writeln('}');
            helperPrinter.line();
        }

        final helpers = helperPrinter.toString();
        if (helpers.length > 0) {
            result = result.replace('\t\t\t{{SHADE_HELPERS}}\n', helpers);
        } else {
            result = result.replace('\t\t\t{{SHADE_HELPERS}}\n', '');
        }

        return result;
    }

    function writePropertiesBlock(printer:Printer, vertData:ShaderClassData, fragData:ShaderClassData, multi:Int):Void {
        printer.writeln('Properties');
        printer.writeln('{');
        printer.indent();

        // Main texture
        if (multi > 0) {
            printer.writeln('[PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}');
            for (i in 1...multi) {
                printer.writeln('[PerRendererData] _Tex$i ("Tex$i", 2D) = "white" {}');
            }
        } else {
            printer.writeln('[PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}');
        }

        // Standard blend properties
        printer.writeln('_SrcBlendRgb ("Src Rgb", Float) = 0');
        printer.writeln('_DstBlendRgb ("Dst Rgb", Float) = 0');
        printer.writeln('_SrcBlendAlpha ("Src Alpha", Float) = 0');
        printer.writeln('_DstBlendAlpha ("Dst Alpha", Float) = 0');
        printer.writeln('_StencilComp ("Stencil Comp", Float) = 8');

        // Custom uniforms from fragment shader (excluding Sampler2D types which are handled above)
        // Note: mat2/mat3 are not declared in Properties block - they use float arrays declared in CGPROGRAM
        for (varField in fragData.varFields) {
            final field = varField.field;
            if (field.meta.has('param') && !field.meta.has('multi') && !ShaderUtils.isSampler2DType(field.type)) {
                // Skip mat2/mat3 - they can't be in Properties block (arrays not supported)
                if (ShaderUtils.isMat2Type(field.type) || ShaderUtils.isMat3Type(field.type)) {
                    continue;
                }
                final propType = getUnityPropertyType(field.type);
                if (propType != null) {
                    printer.writeln('${field.name}_ ("${field.name}", $propType) = ${getUnityPropertyDefault(field.type)}');
                }
            }
        }

        printer.unindent();
        printer.writeln('}');
        printer.line();
    }

    function writeAppdataStruct(printer:Printer, vertData:ShaderClassData, ctx:UnityContext):Void {
        printer.writeln('struct appdata_t');
        printer.writeln('{');
        printer.indent();

        // Iterate over all @in fields from the vertex shader
        var texcoordIndex = 0;
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('in')) {
                // Skip @multi fields (these are packed into position.w)
                if (field.meta.has('multi')) {
                    continue;
                }

                final hlslType = compileHlslType(field.type);
                final name = field.name;

                // Assign semantics based on field name/purpose
                final semantic = getInputSemantic(name, texcoordIndex, ctx);
                if (semantic.startsWith('TEXCOORD')) {
                    texcoordIndex++;
                }

                // Use float4 for position (to accommodate .w for textureId in multi mode)
                final actualType = if (name == ctx.inPosition) 'float4' else hlslType;
                printer.writeln('$actualType ${name}_ : $semantic;');
            }
        }

        printer.unindent();
        printer.writeln('};');
    }

    function getInputSemantic(fieldName:String, texcoordIndex:Int, ctx:UnityContext):String {
        // Map field names to Unity semantics based on detected standard fields
        if (fieldName == ctx.inPosition) return 'POSITION';
        if (fieldName == ctx.inColor) return 'COLOR';
        return 'TEXCOORD$texcoordIndex';
    }

    function writeV2fStruct(printer:Printer, vertData:ShaderClassData, ctx:UnityContext):Void {
        printer.writeln('struct v2f');
        printer.writeln('{');
        printer.indent();

        // position is always first (from vertex shader return value)
        printer.writeln('float4 position : SV_POSITION;');

        // Iterate over all @out fields from the vertex shader
        var texcoordIndex = 0;
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('out')) {
                // Skip @multi fields in non-multi mode
                if (field.meta.has('multi') && ctx.multi == 0) {
                    continue;
                }

                final hlslType = compileHlslTypeForVarying(field.type);
                final name = field.name;

                // Assign semantics based on field name/purpose
                final semantic = getOutputSemantic(name, texcoordIndex, ctx);
                if (semantic.startsWith('TEXCOORD')) {
                    texcoordIndex++;
                }

                printer.writeln('$hlslType ${name}_ : $semantic;');
            }
        }

        printer.unindent();
        printer.writeln('};');
    }

    function getOutputSemantic(fieldName:String, texcoordIndex:Int, ctx:UnityContext):String {
        // Map field names to Unity semantics based on detected standard fields
        if (fieldName == ctx.outColor) return 'COLOR';
        return 'TEXCOORD$texcoordIndex';
    }

    function compileHlslTypeForVarying(type:Type):String {
        // Use full float precision for varyings to avoid precision issues
        // with values that aren't normalized colors
        return compileHlslType(type);
    }

    function writeVertexFunction(printer:Printer, vertData:ShaderClassData, ctx:UnityContext):Void {
        printer.writeln('v2f vert(appdata_t IN)');
        printer.writeln('{');
        printer.indent();

        printer.writeln('v2f OUT;');
        printer.writeln('OUT.position = UnityObjectToClipPos(IN.${ctx.inPosition}_.xyz);');

        // Build a set of @out field names and @in field names for mapping
        final outFields = new Map<String, Bool>();
        final inFields = new Map<String, Bool>();
        for (varField in vertData.varFields) {
            final field = varField.field;
            if (field.meta.has('out')) {
                outFields.set(field.name, true);
            }
            if (field.meta.has('in')) {
                inFields.set(field.name, true);
            }
        }

        // Set up context for vertex shader expression printing
        ctx.multiShader = VERT;

        // Process all assignments from the vertex shader main() function
        for (funcField in vertData.funcFields) {
            if (funcField.field.name == 'main') {
                switch funcField.expr.expr {
                    case TBlock(el):
                        for (expr in el) {
                            // Skip the return statement (handled by Unity's vertex position)
                            switch expr.expr {
                                case TReturn(_):
                                    continue;
                                case TMeta(m, _):
                                    if (m.name == 'multi') {
                                        // Skip @multi assignments in non-multi shaders
                                        if (ctx.multi == 0) continue;
                                    }
                                case _:
                            }
                            // Process assignments to @out fields
                            if (isOutAssignment(expr, outFields)) {
                                printVertexExpression(printer, expr, ctx, inFields, outFields);
                                if (!printer.endsBlock()) {
                                    printer.endBlock(';');
                                    printer.line();
                                }
                            }
                        }
                    case _:
                }
            }
        }

        printer.line();
        printer.writeln('return OUT;');

        printer.unindent();
        printer.writeln('}');
    }

    function isOutAssignment(expr:TypedExpr, outFields:Map<String, Bool>):Bool {
        // Check if this is an assignment to an @out field
        return switch expr.expr {
            case TBinop(OpAssign, left, _):
                switch left.expr {
                    case TField(e, fa):
                        switch e.expr {
                            case TConst(TThis):
                                switch fa {
                                    case FInstance(_, _, cf):
                                        outFields.exists(cf.get().name);
                                    case _: false;
                                }
                            case _: false;
                        }
                    case _: false;
                }
            case TMeta(_, inner):
                isOutAssignment(inner, outFields);
            case _: false;
        };
    }

    function printVertexExpression(printer:Printer, expr:TypedExpr, ctx:UnityContext, inFields:Map<String, Bool>, outFields:Map<String, Bool>):Void {
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
                    case TBool(b):
                        printer.write(b ? 'true' : 'false');
                    case _:
                }
            case TLocal(v):
                printer.write(v.name);
            case TBinop(op, e1, e2):
                printVertexExpression(printer, e1, ctx, inFields, outFields);
                printer.write(getBinopString(op));
                printVertexExpression(printer, e2, ctx, inFields, outFields);
            case TField(e, fa):
                switch e.expr {
                    case TConst(TThis):
                        switch fa {
                            case FInstance(_, _, cf):
                                final name = cf.get().name;
                                // Check if this is the @in @multi field (maps to IN.{position}.w)
                                if (name == ctx.vertexInputMultiField) {
                                    printer.write('IN.${ctx.inPosition}_.w');
                                }
                                // Check if it's an @in field
                                else if (inFields.exists(name)) {
                                    printer.write('IN.${name}_');
                                }
                                // Check if it's an @out field
                                else if (outFields.exists(name)) {
                                    printer.write('OUT.${name}_');
                                } else {
                                    printer.write('${name}_');
                                }
                            case _:
                        }
                    case _:
                        printVertexExpression(printer, e, ctx, inFields, outFields);
                        printer.write('.');
                        switch fa {
                            case FInstance(_, _, cf):
                                printer.write(cf.get().name);
                            case _:
                        }
                }
            case TParenthesis(e):
                printer.write('(');
                printVertexExpression(printer, e, ctx, inFields, outFields);
                printer.write(')');
            case TMeta(m, e1):
                if (m.name == 'multi' && ctx.multi > 0) {
                    // Process multi assignment
                    printVertexExpression(printer, e1, ctx, inFields, outFields);
                } else if (m.name != 'multi') {
                    printVertexExpression(printer, e1, ctx, inFields, outFields);
                }
            case _:
                // For other expressions, use the regular printExpression
                printExpression(printer, expr, ctx);
        }
    }

    function writeFragmentUniforms(printer:Printer, fragData:ShaderClassData, ctx:UnityContext):Void {
        // All uniforms from fragment shader
        for (varField in fragData.varFields) {
            final field = varField.field;
            if (field.meta.has('param')) {
                if (ShaderUtils.isSampler2DType(field.type)) {
                    // Sampler2D uniform
                    if (field.meta.has('multi') && ctx.multi > 0) {
                        // Multi-texture: output multiple samplers with suffixes
                        printer.writeln('sampler2D _MainTex;');
                        for (i in 1...ctx.multi) {
                            printer.writeln('sampler2D _Tex$i;');
                        }
                    } else {
                        // Single texture
                        printer.writeln('sampler2D _MainTex;');
                    }
                } else if (!field.meta.has('multi')) {
                    // Check for mat2/mat3 types - declare as float arrays
                    if (ShaderUtils.isMat2Type(field.type)) {
                        printer.writeln('float ${field.name}_arr_[4];');
                        ctx.mat2Uniforms.push(field.name);
                    } else if (ShaderUtils.isMat3Type(field.type)) {
                        printer.writeln('float ${field.name}_arr_[9];');
                        ctx.mat3Uniforms.push(field.name);
                    } else {
                        // Other uniform types
                        printer.writeln('${compileHlslType(field.type)} ${field.name}_;');
                    }
                }
            }
        }
    }

    function writeFragmentFunction(printer:Printer, fragData:ShaderClassData, ctx:UnityContext):Void {
        printer.writeln('fixed4 frag(v2f IN) : SV_Target');
        printer.writeln('{');
        printer.indent();

        // Generate mat2/mat3 reconstruction from float arrays
        for (name in ctx.mat2Uniforms) {
            printer.writeln('float2x2 ${name}_ = float2x2(');
            printer.indent();
            printer.writeln('${name}_arr_[0], ${name}_arr_[2],');
            printer.writeln('${name}_arr_[1], ${name}_arr_[3]');
            printer.unindent();
            printer.writeln(');');
        }
        for (name in ctx.mat3Uniforms) {
            printer.writeln('float3x3 ${name}_ = float3x3(');
            printer.indent();
            printer.writeln('${name}_arr_[0], ${name}_arr_[3], ${name}_arr_[6],');
            printer.writeln('${name}_arr_[1], ${name}_arr_[4], ${name}_arr_[7],');
            printer.writeln('${name}_arr_[2], ${name}_arr_[5], ${name}_arr_[8]');
            printer.unindent();
            printer.writeln(');');
        }

        // Find and compile main function
        for (funcField in fragData.funcFields) {
            final field = funcField.field;
            if (field.name == 'main') {
                switch funcField.expr.expr {
                    case TBlock(el):
                        for (expr in el) {
                            switch expr.expr {
                                case TReturn(e):
                                    printer.write('return ');
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
                        printer.write('return ');
                        printExpression(printer, e, ctx);
                        if (!printer.endsBlock()) {
                            printer.endBlock(';');
                            printer.line();
                        }
                    case _:
                }
            }
        }

        printer.unindent();
        printer.endBlock('}');
        printer.line();
    }

    function writeHelperFunctions(printer:Printer, funcFields:Array<ClassFuncData>, ctx:UnityContext, prefix:String):Void {
        for (funcField in funcFields) {
            final field = funcField.field;
            // Skip main() and constructor
            if (field.name == 'main' || field.name == 'new') continue;

            switch field.type {
                case TFun(args, ret):
                    // Register in helper functions map for call site remapping
                    ctx.helperFunctions.set(field.name, prefix + field.name);

                    // Return type
                    printer.write(compileHlslType(ret));
                    printer.write(' ');
                    printer.write(prefix + field.name);
                    printer.write('(');

                    // Parameters
                    for (i in 0...args.length) {
                        if (i > 0) printer.write(', ');
                        printer.write(compileHlslType(args[i].t));
                        printer.write(' ');
                        printer.write(args[i].name);
                    }
                    printer.write(') ');

                    // Function body
                    printExpression(printer, ShaderUtils.ensureBlock(funcField.expr), ctx);
                    printer.line();
                case _:
            }
        }
    }

    function printExpression(printer:Printer, expr:TypedExpr, ctx:UnityContext):Void {
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
                        printer.write(b ? 'true' : 'false');
                    case TNull:
                    case TThis:
                    case TSuper:
                }
            case TLocal(v):
                printer.write(v.name);
            case TArray(e1, e2):
            case TBinop(op, e1, e2):
                printExpression(printer, e1, ctx);
                printer.write(getBinopString(op));
                printExpression(printer, e2, ctx);
            case TField(e, fa):
                switch e.expr {
                    case TConst(TThis):
                        // Access to 'this' fields - map to IN.xxx or uniform
                        switch fa {
                            case FInstance(c, params, cf):
                                final name = cf.get().name;
                                final fieldMeta = cf.get().meta;
                                final isIn = fieldMeta.has('in');
                                final isUniform = fieldMeta.has('param');

                                // Map fragment inputs (@in fields)
                                if (isIn) {
                                    printer.write('IN.${name}_');
                                } else if (isUniform) {
                                    // Handle uniform fields - check if this is a Sampler2D type
                                    final fieldType = cf.get().type;
                                    if (ShaderUtils.isSampler2DType(fieldType)) {
                                        // This is a texture sampler
                                        if (ctx.multiTextureField == name && ctx.multiCurrentSlot >= 0) {
                                            if (ctx.multiCurrentSlot == 0) {
                                                printer.write('_MainTex');
                                            } else {
                                                printer.write('_Tex${ctx.multiCurrentSlot}');
                                            }
                                        } else if (ctx.mainTextureField == name) {
                                            printer.write('_MainTex');
                                        } else {
                                            // Other texture samplers (not main texture)
                                            printer.write('${name}_');
                                        }
                                    } else {
                                        printer.write('${name}_');
                                    }
                                } else {
                                    printer.write('${name}_');
                                }
                            case _:
                        }
                    case _:
                        printExpression(printer, e, ctx);
                        printer.write('.');
                        switch fa {
                            case FInstance(c, params, cf):
                                printer.write(cf.get().name);
                            case FStatic(c, cf):
                            case FAnon(cf):
                            case FDynamic(s):
                            case FClosure(c, cf):
                            case FEnum(e, ef):
                        }
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

                // Map function names and handle special cases
                var funcName = getFunctionName(e);

                // Special handling for atan with 2 arguments (swap parameters)
                if (funcName == 'atan' && el.length == 2) {
                    printer.write('atan2(');
                    printExpression(printer, el[1], ctx); // x (second arg in GLSL becomes first in HLSL)
                    printer.write(', ');
                    printExpression(printer, el[0], ctx); // y (first arg in GLSL becomes second in HLSL)
                    printer.write(')');
                    return;
                }

                // Special handling for textureLod -> tex2Dlod with float4 wrapper
                if (funcName == 'textureLod' && el.length == 3) {
                    printer.write('tex2Dlod(');
                    printExpression(printer, el[0], ctx); // sampler
                    printer.write(', float4(');
                    printExpression(printer, el[1], ctx); // uv
                    printer.write(', 0, ');
                    printExpression(printer, el[2], ctx); // lod
                    printer.write('))');
                    return;
                }

                // Special handling for textureGrad -> tex2Dgrad
                if (funcName == 'textureGrad' && el.length == 4) {
                    printer.write('tex2Dgrad(');
                    printExpression(printer, el[0], ctx); // sampler
                    printer.write(', ');
                    printExpression(printer, el[1], ctx); // uv
                    printer.write(', ');
                    printExpression(printer, el[2], ctx); // ddx
                    printer.write(', ');
                    printExpression(printer, el[3], ctx); // ddy
                    printer.write(')');
                    return;
                }

                // Special handling for textureProj -> tex2Dproj
                if (funcName == 'textureProj') {
                    printer.write('tex2Dproj(');
                    for (i in 0...el.length) {
                        if (i > 0) printer.write(', ');
                        printExpression(printer, el[i], ctx);
                    }
                    printer.write(')');
                    return;
                }

                // Special handling for vector constructors with single argument
                // HLSL doesn't support float4(1.0), must be float4(1.0, 1.0, 1.0, 1.0)
                if ((funcName == 'vec2' || funcName == 'vec3' || funcName == 'vec4') && el.length == 1) {
                    final hlslType = mapTypeName(funcName);
                    final componentCount = switch funcName {
                        case 'vec2': 2;
                        case 'vec3': 3;
                        case 'vec4': 4;
                        case _: 0;
                    };
                    printer.write('$hlslType(');
                    for (i in 0...componentCount) {
                        if (i > 0) printer.write(', ');
                        printExpression(printer, el[0], ctx);
                    }
                    printer.write(')');
                    return;
                }

                // Check if it's a helper function that needs prefixing
                if (ctx.helperFunctions.exists(funcName)) {
                    funcName = ctx.helperFunctions.get(funcName);
                } else {
                    funcName = mapFunctionName(funcName, ctx);
                }

                printer.write(funcName);
                printer.write('(');
                for (i in 0...el.length) {
                    if (i > 0) {
                        printer.write(', ');
                    }
                    printExpression(printer, el[i], ctx);
                }
                printer.write(')');

            case TNew(c, params, el):
                // Not used in the shader DSL (vector constructors come through as TCall)
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
                printer.write(compileHlslType(v.t));
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
                printer.write('return ');
                printExpression(printer, e, ctx);
            case TBreak:
            case TContinue:
            case TThrow(e):
            case TCast(e, m):
            case TMeta(m, e1):
                if (m.name == 'multi') {
                    if (ctx.multiShader == FRAG && ctx.multi > 0) {
                        if (ctx.multiSlotField != null) {
                            for (i in 0...ctx.multi) {
                                if (i > 0) {
                                    printer.write('else ');
                                }
                                printer.write('if (IN.${ctx.multiSlotField}_ == ${i}.0) ');
                                printer.writeln('{');
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
                    } else if (ctx.multiShader == FRAG || (ctx.multiShader == VERT && ctx.multi > 0)) {
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

    function printAbstractOp(printer:Printer, meta:MetadataEntry, el:Array<TypedExpr>, ctx:UnityContext):Void {
        switch meta.params[0].expr {
            case EBinop(op, e1, e2):
                // Check if this is matrix/vector multiplication - needs mul() in HLSL
                if (op == OpMult && (ShaderUtils.isMatrixType(el[0].t) || ShaderUtils.isMatrixType(el[1].t))) {
                    printer.write('mul(');
                    printExpression(printer, el[0], ctx);
                    printer.write(', ');
                    printExpression(printer, el[1], ctx);
                    printer.write(')');
                    return;
                }

                final needsParensLeft = needsParenthesesForPrecedence(el[0], op);
                if (needsParensLeft)
                    printer.write('(');
                printExpression(printer, el[0], ctx);
                if (needsParensLeft)
                    printer.write(')');
                printer.write(getBinopString(op));
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

    function needsParenthesesForPrecedence(expr:TypedExpr, outerOp:Binop):Bool {
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

    function getBinopString(op:Binop):String {
        return switch op {
            case OpAdd: ' + ';
            case OpMult: ' * ';
            case OpDiv: ' / ';
            case OpSub: ' - ';
            case OpAssign: ' = ';
            case OpEq: ' == ';
            case OpNotEq: ' != ';
            case OpGt: ' > ';
            case OpGte: ' >= ';
            case OpLt: ' < ';
            case OpLte: ' <= ';
            case OpAnd: ' & ';
            case OpOr: ' | ';
            case OpBoolAnd: ' && ';
            case OpBoolOr: ' || ';
            case OpMod: ' % ';
            case OpAssignOp(subOp):
                switch subOp {
                    case OpAdd: ' += ';
                    case OpMult: ' *= ';
                    case OpDiv: ' /= ';
                    case OpSub: ' -= ';
                    case OpMod: ' %= ';
                    case _: ' = ';
                }
            case _: ' ';
        }
    }

    function getFunctionName(e:TypedExpr):String {
        return switch e.expr {
            case TField(_, fa):
                switch fa {
                    case FInstance(_, _, cf): cf.get().name;
                    case FStatic(_, cf): cf.get().name;
                    case _: '';
                }
            case TLocal(v): v.name;
            case _: '';
        }
    }

    function mapFunctionName(name:String, ctx:UnityContext):String {
        return switch name {
            // Vector constructor functions
            case 'vec2': 'float2';
            case 'vec3': 'float3';
            case 'vec4': 'float4';
            // Matrix constructor functions
            case 'mat2': 'float2x2';
            case 'mat3': 'float3x3';
            case 'mat4': 'float4x4';
            // Texture sampling (with Y-flip for Unity)
            case 'texture':
                ctx.needsShadeTextureHelper = true;
                'shade_texture';
            // Math functions with different names
            case 'mix': 'lerp';
            case 'fract': 'frac';
            case 'inversesqrt': 'rsqrt';
            // Derivative functions
            case 'dFdx': 'ddx';
            case 'dFdy': 'ddy';
            case 'dFdxCoarse': 'ddx_coarse';
            case 'dFdyCoarse': 'ddy_coarse';
            case 'dFdxFine': 'ddx_fine';
            case 'dFdyFine': 'ddy_fine';
            // mod() needs special handling - use shade_mod helper
            case 'mod':
                ctx.needsShadeModHelper = true;
                'shade_mod';
            case _: name;
        }
    }

    function compileHlslType(type:Type):String {
        return switch type {
            case TInst(t, params):
                final name = t.get().name;
                mapTypeName(name);
            case TAbstract(t, params):
                final name = t.get().name;
                mapTypeName(name);
            case _:
                'float';
        }
    }

    function mapTypeName(name:String):String {
        return switch name.toLowerCase() {
            // Vector types
            case 'vec2': 'float2';
            case 'vec3': 'float3';
            case 'vec4': 'float4';
            // Integer vector types (for future-proofing)
            case 'ivec2': 'int2';
            case 'ivec3': 'int3';
            case 'ivec4': 'int4';
            // Unsigned integer vector types (for future-proofing)
            case 'uvec2': 'uint2';
            case 'uvec3': 'uint3';
            case 'uvec4': 'uint4';
            // Boolean vector types (for future-proofing)
            case 'bvec2': 'bool2';
            case 'bvec3': 'bool3';
            case 'bvec4': 'bool4';
            // Matrix types
            case 'mat2': 'float2x2';
            case 'mat3': 'float3x3';
            case 'mat4': 'float4x4';
            // Non-square matrix types (for future-proofing)
            case 'mat2x3': 'float2x3';
            case 'mat2x4': 'float2x4';
            case 'mat3x2': 'float3x2';
            case 'mat3x4': 'float3x4';
            case 'mat4x2': 'float4x2';
            case 'mat4x3': 'float4x3';
            // Sampler types
            case 'sampler2d': 'sampler2D';
            case 'sampler3d': 'sampler3D';
            case 'samplercube': 'samplerCUBE';
            // Scalar types
            case 'int': 'int';
            case 'uint': 'uint';
            case 'float': 'float';
            case 'bool': 'bool';
            case _: name;
        }
    }

    function getUnityPropertyType(type:Type):String {
        return switch type {
            case TInst(t, params):
                final name = t.get().name.toLowerCase();
                switch name {
                    case 'vec2' | 'vec3' | 'vec4': 'Vector';
                    case 'sampler2d': '2D';
                    case _: 'Float';
                }
            case TAbstract(t, params):
                final name = t.get().name.toLowerCase();
                switch name {
                    case 'float' | 'int': 'Float';
                    case _: 'Float';
                }
            case _: 'Float';
        }
    }

    function getUnityPropertyDefault(type:Type):String {
        return switch type {
            case TInst(t, params):
                final name = t.get().name.toLowerCase();
                switch name {
                    case 'vec2' | 'vec3' | 'vec4': '(0,0,0,0)';
                    case 'sampler2d': '"white" {}';
                    case _: '0';
                }
            case _: '0';
        }
    }
}

@:structInit
class ShaderClassData {
    public var classType:ClassType;
    public var varFields:Array<ClassVarData>;
    public var funcFields:Array<ClassFuncData>;
}

@:structInit
class UnityContext {
    public var multi:Int;
    public var multiShader:ShaderKind;
    public var multiSlotField:String = null;
    public var multiTextureField:String = null;
    public var multiCurrentSlot:Int = -1;
    public var needsShadeModHelper:Bool = false;
    public var needsShadeTextureHelper:Bool = false;
    // For vertex shader: the @in @multi field name (e.g., "vertexTextureId")
    public var vertexInputMultiField:String = null;
    // The name of the main texture uniform field (detected by Sampler2D type)
    public var mainTextureField:String = null;
    // Standard vertex input field names (first 3 @in fields: position, tcoord, color)
    public var inPosition:String = null;
    public var inTCoord:String = null;
    public var inColor:String = null;
    // Standard vertex output field names (first 3 @out fields: tcoord, color, then multi slot)
    public var outTCoord:String = null;
    public var outColor:String = null;
    public var outMultiSlot:String = null;
    // Helper function name mapping (original name -> prefixed name)
    public var helperFunctions:Map<String, String> = new Map();
    // Mat2/mat3 uniform field names (for reconstruction in main())
    public var mat2Uniforms:Array<String> = [];
    public var mat3Uniforms:Array<String> = [];
}

#end
