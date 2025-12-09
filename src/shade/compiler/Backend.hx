package shade.compiler;

#if (macro || shade_compiler)

import haxe.macro.Type;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.output.OutputPath;

/**
 * Interface for shader output backends.
 * Each backend has full control over how to generate shader output.
 */
interface Backend {
    /** Unique identifier for this backend (e.g., "glsl", "unity") */
    var id(default, null):String;

    /**
     * Generate shader output for a class.
     * Backend has full control over what files to generate and their content.
     * @param classType The shader class being compiled
     * @param varFields Class variables with metadata (@uniform, @in, @out, @multi)
     * @param funcFields Class functions including main()
     * @param setExtraFile Callback to output files
     */
    function generate(
        classType:ClassType,
        varFields:Array<ClassVarData>,
        funcFields:Array<ClassFuncData>,
        setExtraFile:(filename:OutputPath, content:String) -> Void
    ):Void;
}

#end
