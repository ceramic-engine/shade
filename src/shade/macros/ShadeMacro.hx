package shade.macros;

import haxe.DynamicAccess;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef ShadeMacroParam = { name: String, type: shade.ParamType, ?def: ExprDef, ?doc: String, ?texSlot: Int, ?pos: Position };

typedef ShadeMacroVertexAttribute = { name: String, index: Int, type: shade.ParamType, ?doc: String, ?pos: Position, ?multi: Bool };

typedef ShadeMacroShaderReference = { pack: Array<String>, name: String, filePath: String, hash: String, multi: Bool };

class ShadeMacro {

    @:persistent static var shaderTypeByImplName:Map<String,ComplexType> = null;

    @:persistent static var shaderParamsByType:Map<String,Array<ShadeMacroParam>> = null;

    @:persistent static var shaderVertexAttributesByType:Map<String,Array<ShadeMacroVertexAttribute>> = null;

    /**
     * Collects all shader class references.
     */
    @:persistent static var shaderReferences:Array<ShadeMacroShaderReference> = [];

    /**
     * Cache of file content hashes to avoid redundant file reads.
     */
    static var fileHashes:Map<String,String> = new Map();

    /**
     * Computes or retrieves cached MD5 hash of a file's content.
     * @param filePath Path to the file to hash
     * @return MD5 hash string
     */
    static function getHash(filePath:String):String {
        var hash = fileHashes.get(filePath);
        if (hash == null) {
            hash = haxe.crypto.Md5.encode(sys.io.File.getContent(filePath));
            fileHashes.set(filePath, hash);
        }
        return hash;
    }

    /**
     * Registers a post-generation hook to output.
     * This requires external setup to work correctly (Ceramic or similar).
     */
    public static function initRegister(targetPath:String):Void {

        var isCompletion = Context.defined('completion');
        if (!isCompletion) {
            if (targetPath != null) {
                Context.onAfterGenerate(function() {
                    shaderReferences.sort(function(a, b) {
                        if (a.filePath < b.filePath) return -1;
                        if (a.filePath > b.filePath) return 1;
                        if (a.hash < b.hash) return -1;
                        if (a.hash > b.hash) return 1;
                        return 0;
                    });
                    if (!sys.FileSystem.exists(haxe.io.Path.join([targetPath, 'shade']))) {
                        sys.FileSystem.createDirectory(haxe.io.Path.join([targetPath, 'shade']));
                    }
                    sys.io.File.saveContent(haxe.io.Path.join([targetPath, 'shade', 'info.json']), haxe.Json.stringify({
                        shaders: shaderReferences
                    }));
                });
            }
        }

    }

    static function registerShaderReference(ref:ShadeMacroShaderReference) {
        for (existing in shaderReferences) {
            if (existing.name == ref.name && arraysEqual(existing.pack, ref.pack)) {
                if (existing.hash != ref.hash) {
                    existing.filePath = ref.filePath;
                    existing.hash = ref.hash;
                }
                return;
            }
        }
        shaderReferences.push(ref);
    }

    static function arraysEqual(a:Array<String>, b:Array<String>):Bool {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        if (a.length != b.length) return false;
        for (i in 0...a.length) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }

    static function getOrCreateShaderParam(list:Array<ShadeMacroParam>, name:String):ShadeMacroParam {
        for (i in 0...list.length) {
            if (list[i].name == name) return list[i];
        }
        var result:Dynamic = { name: name };
        list.push(result);
        return result;
    }

    static function getOrCreateShaderVertexAttribute(list:Array<ShadeMacroVertexAttribute>, name:String):ShadeMacroVertexAttribute {
        for (i in 0...list.length) {
            if (list[i].name == name) return list[i];
        }
        var result:Dynamic = { name: name };
        list.push(result);
        return result;
    }

    macro static public function buildShaderForHaxe():ComplexType {

        var localType = Context.getLocalType();
        var currentPos = Context.currentPos();

        if (shaderTypeByImplName == null) {
            shaderTypeByImplName = new Map();
        }

        switch localType {
            case TInst(t, [TInst(vertTypeRef, vertParams), TInst(fragTypeRef, fragParams)]):
                final vertType = vertTypeRef.get();
                final fragType = fragTypeRef.get();
                final fullName = 'Shader__' + vertType.pack.join('_') + '_' + vertType.name + '__' + fragType.pack.join('_') + '_' + fragType.name;

                var resolvedType:Type = null;
                try {
                    resolvedType = Context.getType('shade.$fullName');
                }
                catch (e:Any) {}

                if (resolvedType != null && shaderTypeByImplName.exists(fullName)) {
                    return shaderTypeByImplName.get(fullName);
                }

                final shaderType = createShaderType(Context.currentPos(), fullName, localType, vertType, fragType);
                shaderTypeByImplName.set(fullName, shaderType);
                return shaderType;

            case _:
        }

        Context.error("Invalid shader type: " + localType, Context.currentPos());
        return null;

    }

    static function createShaderType(
        currentPos:Position,
        fullName:String,
        localType:Type,
        vertType:ClassType,
        fragType:ClassType
    ) {
        // Don't process any type for the abstract shader class
        if (fullName == 'Shader__shade_Vert__shade_Frag') {
            return macro :Any;
        }

        final fields:Array<Field> = [];
        final paramInfo = new Map<String, ShadeMacroParam>();

        var vertClassKey = (vertType.pack != null && vertType.pack.length > 0 ? vertType.pack.join('.') + '.' : '') + vertType.name;
        var fragClassKey = (fragType.pack != null && fragType.pack.length > 0 ? fragType.pack.join('.') + '.' : '') + fragType.name;

        var vertParamsData = shaderParamsByType.get(vertClassKey);
        var fragParamsData = shaderParamsByType.get(fragClassKey);

        var vertAttributesData = shaderVertexAttributesByType.get(vertClassKey);

        // Gather params/uniforms
        for (info in vertParamsData) {
            paramInfo.set(info.name, info);
        }
        for (info in fragParamsData) {
            paramInfo.set(info.name, info);
        }

        // Create params/uniform setters
        for (name => info in paramInfo) {
            final setFieldName = #if (ceramic || shade_ceramic_style_setters) name #else 'set${name.charAt(0).toUpperCase()}${name.substr(1)}' #end;
            final setters = createShaderParamSetters(name, info);
            for (setter in setters) {
                fields.push({
                    name: setFieldName,
                    pos: info.pos ?? currentPos,
                    access: [APublic, AExtern, AInline, AOverload],
                    doc: info.doc,
                    kind: setter
                });
            }
        }

        // Override texture slot result
        var textureSlotsExpr = new StringBuf();
        textureSlotsExpr.addChar('{'.code);
        textureSlotsExpr.addChar('\n'.code);
        textureSlotsExpr.add('return switch name {\n');
        for (name => info in paramInfo) {
            if (info.type == Sampler2D) {
                textureSlotsExpr.add('case "$name": ${info.texSlot};\n');
            }
        }
        textureSlotsExpr.add('case _: -1;');
        textureSlotsExpr.addChar('\n'.code);
        textureSlotsExpr.addChar('}'.code);
        textureSlotsExpr.addChar('\n'.code);
        textureSlotsExpr.addChar('}'.code);
        fields.push({
            name: 'resolveTextureSlot',
            pos: currentPos,
            access: [AOverride],
            kind: FFun({
                args: [{
                    name: 'name',
                    type: macro :String
                }],
                ret: macro :Int,
                expr: Context.parse(textureSlotsExpr.toString(), currentPos)
            })
        });

        #if ceramic
        // Auto-populate attributes in constructor
        var constructorExpr = new StringBuf();
        constructorExpr.addChar('{'.code);
        constructorExpr.addChar('\n'.code);
        var textureIdAttribute = null;
        if (vertAttributesData.length > 3) {
            constructorExpr.add('super([');
            // Custom attributes
            var numItems = 0;
            for (i in 0...vertAttributesData.length) {
                if (i >= 3) {
                    if (numItems > 0) {
                        constructorExpr.addChar(','.code);
                    }
                    if (vertAttributesData[i].name == 'vertexTextureId' && vertAttributesData[i].multi != null && vertAttributesData[i].multi == true) {
                        textureIdAttribute = vertAttributesData[i];
                    }
                    else {
                        numItems++;
                        constructorExpr.add('{ size: ${sizeFromType(vertAttributesData[i].type)}, name: "${vertAttributesData[i].name}" }\n');
                    }
                }
            }
            constructorExpr.add('],[');
        }
        else {
            constructorExpr.add('super(null, [');
        }
        // Base attributes
        for (i in 0...vertAttributesData.length) {
            if (i < 3) {
                if (i > 0) {
                    constructorExpr.addChar(','.code);
                }
                constructorExpr.add('{ size: ${sizeFromType(vertAttributesData[i].type)}, name: "${vertAttributesData[i].name}" }\n');
            }
        }
        constructorExpr.add(']');
        if (textureIdAttribute != null) {
            constructorExpr.add(',{ size: ${sizeFromType(textureIdAttribute.type)}, name: "${textureIdAttribute.name}" }');
        }
        else {
            constructorExpr.add(',null');
        }
        constructorExpr.add(');');
        constructorExpr.addChar('\n'.code);
        constructorExpr.addChar('}'.code);
        fields.push({
            name: 'new',
            pos: currentPos,
            access: [APublic],
            kind: FFun({
                args: [],
                expr: Context.parse(constructorExpr.toString(), currentPos)
            })
        });
        #end

        Context.defineType({
            pack: ['shade'],
            name: fullName,
            pos: currentPos,
            kind: TDClass(
            #if shade_base_shader
            {
                pack: ['shade'],
                name: 'BaseShader',
                params: []
            }
            #end
            ),
            fields: fields,
            meta: [{
                name: ':autoBuild',
                params: [ macro shade.macros.ShadeMacro.buildShaderClassFields()],
                pos: currentPos
            }]
        });

        return TPath({
            pack: ['shade'],
            name: fullName
        });

    }

    macro static function buildShaderClassFields():Array<Field> {

        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        var superClass = localClass.superClass.t.get();
        var currentPos = Context.currentPos();

        var multi = false;

        // Checking vertex shader is enough, to know if multi texture is supported
        var nameParts = superClass.name.split('__');
        final vertKey = typePathFromUnderscoredType(nameParts[1]);
        final attributes =  shaderVertexAttributesByType.get(vertKey);
        if (attributes != null) {
            for (attr in attributes) {
                if (attr.multi == true) {
                    multi = true;
                    break;
                }
            }
        }

        // Register file
        var filePath = Context.getPosInfos(currentPos).file;
        if (!Path.isAbsolute(filePath)) {
            filePath = Path.join([Sys.getCwd(), filePath]);
        }
        registerShaderReference({
            pack: localClass.pack,
            name: localClass.name,
            filePath: filePath,
            hash: getHash(filePath),
            multi: false
        });

        return fields;

    }

    static function typePathFromUnderscoredType(underscoredType:String):String {

        var keyParts = underscoredType.split('_');
        var isPack = true;
        var keyBuf = new StringBuf();
        for (i in 0...keyParts.length) {
            if (i > 0) {
                keyBuf.addChar(isPack ? '.'.code : '_'.code);
            }
            final part = keyParts[i];
            if (isPack) {
                isPack = (part.toLowerCase() == part);
            }
            keyBuf.add(part);
        }
        return keyBuf.toString();

    }

    static function sizeFromType(type:shade.ParamType):Int {

        return switch type {
            case Float: 1;
            case Vec2: 2;
            case Vec3: 3;
            case Vec4: 4;
            case Mat2: 4;
            case Mat3: 9;
            case Mat4: 16;
            case Sampler2D: 1;
        }

    }

    static function createShaderParamSetters(name:String, param:ShadeMacroParam):Array<FieldType> {

        final result:Array<FieldType> = [];

        switch param.type {
            case Float:
                result.push(FFun({
                    args: [
                        {
                            name: 'value',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setFloat($v{name}, value);
                    },
                    ret: macro :Void
                }));
            case Vec2:
                result.push(FFun({
                    args: [
                        {
                            name: 'x',
                            type: macro :Float
                        },
                        {
                            name: 'y',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setVec2($v{name}, x, y);
                    },
                    ret: macro :Void
                }));
            case Vec3:
                result.push(FFun({
                    args: [
                        {
                            name: 'x',
                            type: macro :Float
                        },
                        {
                            name: 'y',
                            type: macro :Float
                        },
                        {
                            name: 'z',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setVec3($v{name}, x, y, z);
                    },
                    ret: macro :Void
                }));

                #if ceramic
                // Color overload
                result.push(FFun({
                    args: [
                        {
                            name: 'color',
                            type: macro :ceramic.Color
                        }
                    ],
                    expr: macro {
                        this.setVec3($v{name}, color);
                    },
                    ret: macro :Void
                }));
                #end
            case Vec4:
                result.push(FFun({
                    args: [
                        {
                            name: 'x',
                            type: macro :Float
                        },
                        {
                            name: 'y',
                            type: macro :Float
                        },
                        {
                            name: 'z',
                            type: macro :Float
                        },
                        {
                            name: 'w',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setVec4($v{name}, x, y, z, w);
                    },
                    ret: macro :Void
                }));

                #if ceramic
                // AlphaColor overload
                result.push(FFun({
                    args: [
                        {
                            name: 'alphaColor',
                            type: macro :ceramic.AlphaColor
                        }
                    ],
                    expr: macro {
                        this.setVec4($v{name}, alphaColor);
                    },
                    ret: macro :Void
                }));

                // Color overload
                result.push(FFun({
                    args: [
                        {
                            name: 'color',
                            type: macro :ceramic.Color
                        }
                    ],
                    expr: macro {
                        this.setVec4($v{name}, color);
                    },
                    ret: macro :Void
                }));
                #end
            case Mat2:
                result.push(FFun({
                    args: [
                        {
                            name: 'm00',
                            type: macro :Float
                        },
                        {
                            name: 'm10',
                            type: macro :Float
                        },
                        {
                            name: 'm01',
                            type: macro :Float
                        },
                        {
                            name: 'm11',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setMat2($v{name}, m00, m10, m01, m11);
                    },
                    ret: macro :Void
                }));
            case Mat3:
                // Raw matrix values overload
                result.push(FFun({
                    args: [
                        {
                            name: 'm00',
                            type: macro :Float
                        },
                        {
                            name: 'm10',
                            type: macro :Float
                        },
                        {
                            name: 'm20',
                            type: macro :Float
                        },
                        {
                            name: 'm01',
                            type: macro :Float
                        },
                        {
                            name: 'm11',
                            type: macro :Float
                        },
                        {
                            name: 'm21',
                            type: macro :Float
                        },
                        {
                            name: 'm02',
                            type: macro :Float
                        },
                        {
                            name: 'm12',
                            type: macro :Float
                        },
                        {
                            name: 'm22',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setMat3(
                            $v{name},
                            m00, m10, m20,
                            m01, m11, m21,
                            m02, m12, m22
                        );
                    },
                    ret: macro :Void
                }));

                #if ceramic
                // Transform overload
                result.push(FFun({
                    args: [
                        {
                            name: 'transform',
                            type: macro :ceramic.Transform
                        }
                    ],
                    expr: macro {
                        this.setMat3($v{name}, transform);
                    },
                    ret: macro :Void
                }));
                #end

            case Mat4:
                // Raw matrix values overload
                result.push(FFun({
                    args: [
                        {
                            name: 'm00',
                            type: macro :Float
                        },
                        {
                            name: 'm10',
                            type: macro :Float
                        },
                        {
                            name: 'm20',
                            type: macro :Float
                        },
                        {
                            name: 'm30',
                            type: macro :Float
                        },
                        {
                            name: 'm01',
                            type: macro :Float
                        },
                        {
                            name: 'm11',
                            type: macro :Float
                        },
                        {
                            name: 'm21',
                            type: macro :Float
                        },
                        {
                            name: 'm31',
                            type: macro :Float
                        },
                        {
                            name: 'm02',
                            type: macro :Float
                        },
                        {
                            name: 'm12',
                            type: macro :Float
                        },
                        {
                            name: 'm22',
                            type: macro :Float
                        },
                        {
                            name: 'm32',
                            type: macro :Float
                        },
                        {
                            name: 'm03',
                            type: macro :Float
                        },
                        {
                            name: 'm13',
                            type: macro :Float
                        },
                        {
                            name: 'm23',
                            type: macro :Float
                        },
                        {
                            name: 'm33',
                            type: macro :Float
                        }
                    ],
                    expr: macro {
                        this.setMat4(
                            $v{name},
                            m00, m10, m20, m30,
                            m01, m11, m21, m31,
                            m02, m12, m22, m32,
                            m03, m13, m23, m33
                        );
                    },
                    ret: macro :Void
                }));

                #if ceramic
                // Transform overload
                result.push(FFun({
                    args: [
                        {
                            name: 'transform',
                            type: macro :ceramic.Transform
                        }
                    ],
                    expr: macro {
                        this.setMat4($v{name}, transform);
                    },
                    ret: macro :Void
                }));
                #end

            case Sampler2D:
                result.push(FFun({
                    args: [
                        {
                            name: 'texture',
                            type: macro :shade.Sampler2D
                        }
                    ],
                    expr: macro {
                        this.setTexture($v{name}, texture);
                    },
                    ret: macro :Void
                }));
        }

        return result;

    }

    macro static public function buildFragVertForHaxe():Array<Field> {

        final currentPos = Context.currentPos();
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        var superClass = localClass.superClass.t.get();
        var newFields = [];

        var isShadePack = superClass.pack != null && superClass.pack.length == 1 && superClass.pack[0] == 'shade';
        var isFrag = isShadePack && superClass.name == 'Frag';
        var isVert = isShadePack && superClass.name == 'Vert';

        if (!isFrag && !isVert) {
            Context.error('The type should be a direct subclass or either shade.Vert or shade.Frag.', currentPos);
            return fields;
        }

        var classKey = (localClass.pack != null && localClass.pack.length > 0 ? localClass.pack.join('.') + '.' : '') + localClass.name;

        // Extract information
        if (shaderParamsByType == null) {
            shaderParamsByType = new Map();
        }
        if (shaderVertexAttributesByType == null) {
            shaderVertexAttributesByType = new Map();
        }

        var paramsData = shaderParamsByType.get(classKey);
        if (paramsData == null) {
            paramsData = [];
            shaderParamsByType.set(classKey, paramsData);
        }

        var vertexAttributesData = shaderVertexAttributesByType.get(classKey);
        if (vertexAttributesData == null) {
            vertexAttributesData = [];
            shaderVertexAttributesByType.set(classKey, vertexAttributesData);
        }

        var nextTextureSlot:Int = 0;
        var nextAttributeIndex:Int = 0;
        for (field in fields) {
            switch field.kind {
                case FVar(t, e):
                    if (field.meta != null) {
                        for (meta in field.meta) {
                            if (meta.name == 'param') {
                                // Extract param/uniform
                                final type:ParamType = switch t {
                                    case TPath(p):
                                        ParamType.fromString(p.name);
                                    case _:
                                        null;
                                }
                                final def:ExprDef = switch [type, e?.expr] {
                                    case [Float, _]:
                                        if (e != null) {
                                            EArrayDecl([e]);
                                        }
                                        else {
                                            null;
                                        }
                                    case [Vec2, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('vec2')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Vec3, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('vec3')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Vec4, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('vec4')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Mat2, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('mat2')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Mat3, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('mat3')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Mat4, ECall(e, params)]:
                                        switch e.expr {
                                            case EConst(CIdent('mat4')):
                                                EArrayDecl(params);
                                            case _:
                                                null;
                                        }
                                    case [Sampler2D, _]:
                                        null;
                                    case [_, _]:
                                        null;
                                }
                                var result:Dynamic = getOrCreateShaderParam(paramsData, field.name);
                                result.type = type;
                                if (def != null) {
                                    result.def = def;
                                }
                                if (field.doc != null) {
                                    result.doc = field.doc;
                                }
                                if (type == Sampler2D) {
                                    result.texSlot = nextTextureSlot;
                                    nextTextureSlot++;
                                }
                                result.pos = field.pos;
                            }
                            else if (meta.name == 'in' && isVert) {
                                // Extract vertex attribute
                                final type:ParamType = switch t {
                                    case TPath(p):
                                        ParamType.fromString(p.name);
                                    case _:
                                        null;
                                }
                                var result:Dynamic = getOrCreateShaderVertexAttribute(vertexAttributesData, field.name);
                                result.type = type;
                                if (field.doc != null) {
                                    result.doc = field.doc;
                                }
                                result.index = nextAttributeIndex;
                                nextAttributeIndex++;
                                result.pos = field.pos;
                                for (subMeta in field.meta) {
                                    if (subMeta.name == 'multi') {
                                        result.multi = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }

                case _:
            }
        }

        var paramsMapExpr:Expr = {
            pos: currentPos,
            expr: EArrayDecl([for (val in paramsData) {
                pos: currentPos,
                expr: EBinop(OpArrow, {
                    pos: currentPos,
                    expr: EConst(CString(val.name))
                }, {
                    pos: currentPos,
                    expr: EObjectDecl(val.def != null ? [
                        {
                            field: 'type',
                            expr: {
                                pos: currentPos,
                                expr: EConst(CIdent(val.type.toString()))
                            }
                        },
                        {
                            field: 'def',
                            expr: {
                                pos: currentPos,
                                expr: val.def
                            }
                        }
                    ] : [{
                        field: 'type',
                        expr: {
                            pos: currentPos,
                            expr: EConst(CIdent(val.type.toString()))
                        }
                    }])
                })
            }])
        };

        for (field in fields) {
            #if (completion || display)
            newFields.push(field);
            #else
            switch field.kind {
                case FVar(t, e):
                    if (field.meta != null) {
                        for (meta in field.meta) {
                            if (meta.name == 'param') {
                                // Remove param/uniform default value
                                field.kind = FVar(t, null);
                            }
                        }
                    }
                case FProp(get, set, t, e):
                    newFields.push(field);
                case FFun(f):
                    // Remove shader functions when building an actual
                    // haxe target that is not for code completion.
            }
            #end
        }

        newFields.push({
            name: 'params',
            pos: currentPos,
            access: [AStatic],
            kind: FVar(
                macro :Map<String, { type: shade.ParamType, ?def: Null<Array<Dynamic>> }>,
                paramsMapExpr
            )
        });

        return newFields;

    }

}
