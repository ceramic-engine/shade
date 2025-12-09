package shade.compiler;

#if (macro || shade_compiler)

import reflaxe.ReflectCompiler;
import reflaxe.preprocessors.ExpressionPreprocessor;

class CompilerInit {
    public static function Start() {
        #if !eval
        Sys.println("CompilerInit.Start can only be called from a macro context.");
        return;
        #end

        #if (haxe_ver < "4.3.0")
        Sys.println("Reflaxe/ShadeCompiler requires Haxe version 4.3.0 or greater.");
        return;
        #end

        ReflectCompiler.AddCompiler(new Compiler(), {
            expressionPreprocessors: [
                SanitizeEverythingIsExpression({}),
            ],
            fileOutputExtension: "",
            outputDirDefineName: "shade_output",
            fileOutputType: FilePerClass,
            reservedVarNames: reservedNames(),
            targetCodeInjectionName: "__shade__",
            manualDCE: false,
            trackUsedTypes: false
        });
    }

    static function reservedNames() {
        return [];
    }
}

#end
