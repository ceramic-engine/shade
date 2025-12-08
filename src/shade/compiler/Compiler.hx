package shade.compiler;

#if (macro || shade_runtime)

import haxe.macro.Type;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

using StringTools;

/**
 * Main shader compiler - thin orchestrator that dispatches to a backend.
 */
class Compiler extends DirectToStringCompiler {
    var backend:Backend;

    public function new() {
        super();

        // Select backend based on define
        #if shade_glsl
        backend = new shade.backend.GlslBackend();
        #elseif shade_unity
        backend = new shade.backend.UnityBackend();
        #elseif shade_custom
        backend = new shade.backend.CustomBackend();
        #else
        #if !display
        throw "ShadeCompiler: No backend specified. Use -D shade_glsl or -D shade_unity";
        #end
        #end
    }

    override function shouldGenerateClass(classType:ClassType):Bool {
        if (!super.shouldGenerateClass(classType))
            return false;

        final parent = classType.superClass?.t.get();
        if (parent != null) {
            if (parent.pack != null && parent.pack.length == 1 && parent.pack[0] == 'shade') {
                if (parent.name == 'Vert' && classType.name.endsWith('_Vert')) {
                    return true;
                } else if (parent.name == 'Frag' && classType.name.endsWith('_Frag')) {
                    return true;
                }
            }
        }
        return false;
    }

    override function shouldGenerateEnum(enumType:EnumType):Bool {
        return false;
    }

    public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String> {
        backend.generate(classType, varFields, funcFields, setExtraFile);
        return null;
    }

    public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<String> {
        return null;
    }

    public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<String> {
        return null;
    }
}

#end
