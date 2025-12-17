package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * CLI entry point for `haxelib run shade`
 *
 * Transpiles Haxe shader files to GLSL or Unity shader formats.
 */
var commandRunDir:String = "";
var shadeRoot:String = "";

function main() {
	final args = Sys.args();

	// Last argument is the directory where the command was invoked
	commandRunDir = args.pop();

	// Determine shade library root (where this Run.hx is located)
	shadeRoot = Path.directory(FileSystem.absolutePath(Sys.programPath()));

	if (args.length == 0 || args[0] == "help" || args[0] == "--help" || args[0] == "-h") {
		printHelp();
		return;
	}

	// Ensure reflaxe is set up as a dev library
	setupReflaxe();

	transpileShaders(args);
}

function transpileShaders(args:Array<String>) {
	// Parse arguments
	var hxFiles:Array<String> = [];
	var outputPath:Null<String> = null;
	var target:Null<String> = null;
	var extraHxml:Null<String> = null;

	var i = 0;
	while (i < args.length) {
		final arg = args[i];
		if (arg == "--in" && i + 1 < args.length) {
			var file = args[i + 1];
			if (!Path.isAbsolute(file)) {
				file = Path.join([commandRunDir, file]);
			}
			hxFiles.push(file);
			i += 2;
		} else if (arg == "--out" && i + 1 < args.length) {
			outputPath = args[i + 1];
			if (!Path.isAbsolute(outputPath)) {
				outputPath = Path.join([commandRunDir, outputPath]);
			}
			i += 2;
		} else if (arg == "--target" && i + 1 < args.length) {
			target = args[i + 1];
			i += 2;
		} else if (arg == "--hxml" && i + 1 < args.length) {
			extraHxml = args[i + 1];
			i += 2;
		} else {
			i++;
		}
	}

	// Validate arguments
	if (hxFiles.length == 0) {
		printError("Error: At least one --in argument is required");
		printHelp();
		Sys.exit(1);
		return;
	}

	if (target == null) {
		printError("Error: --target argument is required (glsl or unity)");
		printHelp();
		Sys.exit(1);
		return;
	}

	if (target != "glsl" && target != "unity" && target != "custom") {
		printError('Error: Unknown target "$target". Valid targets: glsl, unity, custom');
		Sys.exit(1);
		return;
	}

	if (outputPath == null) {
		outputPath = commandRunDir;
	}

	// Verify input files exist
	for (hxFile in hxFiles) {
		if (!FileSystem.exists(hxFile)) {
			printError('Error: Input file not found: $hxFile');
			Sys.exit(1);
			return;
		}
	}

	// Step 1: Create a temporary directory
	final tempDir = createTempDir("shade-compile");

	// Step 2: Copy shader files with correct package structure
	for (hxFile in hxFiles) {
		final pkg = extractPackageFromHaxeFile(hxFile);
		final typeName = getTypeName(hxFile);

		var destPath:String;
		if (pkg != null) {
			final pkgPath = pkg.replace(".", "/");
			destPath = Path.join([tempDir, pkgPath, typeName + ".hx"]);
		} else {
			destPath = Path.join([tempDir, typeName + ".hx"]);
		}

		copyFile(hxFile, destPath);
	}

	// Step 3: Generate import.hx
	final importContent = "import shade.*;\nimport shade.Functions.*;\n";
	File.saveContent(Path.join([tempDir, "import.hx"]), importContent);

	// Step 4: Generate Main.hx
	final mainContent = new StringBuf();
	for (hxFile in hxFiles) {
		final fullType = getFullTypePath(hxFile);
		mainContent.add('import $fullType;\n');
	}
	mainContent.add("\nfunction main() {\n}\n");
	File.saveContent(Path.join([tempDir, "Main.hx"]), mainContent.toString());

	// Step 5: Generate build.hxml
	final shadePath = Path.join([shadeRoot, "src"]);
	final shadeOutputDir = Path.join([tempDir, "shade-out"]);

	final hxmlContent = new StringBuf();

	// Local class path (the temp dir itself)
	hxmlContent.add("-cp .\n");

	// Reflaxe library (via haxelib, set up by setupReflaxe)
	hxmlContent.add("-lib reflaxe\n");

	// Shade library
	hxmlContent.add('-cp $shadePath\n');
	hxmlContent.add("-D shade\n");

	// Required Haxe compiler settings for reflaxe/shade
	hxmlContent.add("--dce no\n");
	hxmlContent.add("-D analyzer-no-module\n");
	hxmlContent.add("-D retain-untyped-meta\n");

	// Shade compiler initialization
	hxmlContent.add("--macro shade.compiler.CompilerInit.Start()\n");

	// Add target-specific defines
	switch (target) {
		case "glsl":
			hxmlContent.add("-D shade_glsl\n");
		case "unity":
			hxmlContent.add("-D shade_unity\n");
		case "custom":
			hxmlContent.add("-D shade_custom\n");
	}

	// Set output directory
	hxmlContent.add('-D shade_output=$shadeOutputDir\n');

	// Add user-provided hxml if any
	if (extraHxml != null) {
		hxmlContent.add('$extraHxml\n');
	}

	hxmlContent.add("-main Main\n");
	hxmlContent.add("--no-output\n");

	File.saveContent(Path.join([tempDir, "build.hxml"]), hxmlContent.toString());

	// Step 6: Run Haxe compiler
	Sys.println("Compiling shaders...");
	final oldCwd = Sys.getCwd();
	Sys.setCwd(tempDir);
	final result = Sys.command("haxe", ["build.hxml"]);
	Sys.setCwd(oldCwd);

	if (result != 0) {
		printError("Shader compilation failed");
		deleteRecursive(tempDir);
		Sys.exit(1);
		return;
	}

	// Step 7: Copy generated shaders to output directory
	if (!FileSystem.exists(outputPath)) {
		createDirectoryRecursive(outputPath);
	}

	var copiedFiles = 0;
	if (FileSystem.exists(shadeOutputDir)) {
		for (file in FileSystem.readDirectory(shadeOutputDir)) {
			if (file == "_GeneratedFiles.json")
				continue;

			final srcPath = Path.join([shadeOutputDir, file]);
			final dstPath = Path.join([outputPath, file]);

			File.copy(srcPath, dstPath);
			copiedFiles++;
		}
	}

	// Step 8: Clean up temporary directory
	deleteRecursive(tempDir);

	printSuccess('Successfully generated $copiedFiles shader file(s) in: $outputPath');
}

function printHelp() {
	Sys.println("
Shade - Cross-platform shader transpiler

Usage:
  haxelib run shade --in <shader.hx> --target <glsl|unity> [--out <dir>] [--hxml <extra>]

Arguments:
  --in <path>       Input Haxe shader file (can be specified multiple times)
  --target <type>   Target backend: glsl, unity, or custom
  --out <dir>       Output directory (default: current directory)
  --hxml <content>  Additional hxml compiler options

Examples:
  haxelib run shade --in src/Blur.hx --target glsl --out shaders/
  haxelib run shade --in src/Blur.hx --in src/Bloom.hx --target unity --out output/
  haxelib run shade --in src/Custom.hx --target glsl --hxml \"-D my_define\"
");
}

function printError(msg:String) {
	Sys.println('\033[1;31m$msg\033[0m');
}

function printSuccess(msg:String) {
	Sys.println('\033[1;32m$msg\033[0m');
}

function extractPackageFromHaxeFile(filePath:String):Null<String> {
	final content = File.getContent(filePath);
	final packageRegex = ~/^package\s+([a-zA-Z_][a-zA-Z0-9_\.]*)\s*;/m;
	if (packageRegex.match(content)) {
		return packageRegex.matched(1);
	}
	return null;
}

function getTypeName(filePath:String):String {
	return Path.withoutExtension(Path.withoutDirectory(filePath));
}

function getFullTypePath(filePath:String):String {
	final pkg = extractPackageFromHaxeFile(filePath);
	final typeName = getTypeName(filePath);
	return pkg != null ? '$pkg.$typeName' : typeName;
}

function createTempDir(prefix:String):String {
	final tempBase = switch (Sys.systemName()) {
		case "Windows": Sys.getEnv("TEMP");
		case _: "/tmp";
	}
	final timestamp = Date.now().getTime();
	final random = Std.random(100000);
	final tempDir = Path.join([tempBase, '${prefix}_${timestamp}_$random']);
	createDirectoryRecursive(tempDir);
	return tempDir;
}

function createDirectoryRecursive(path:String) {
	if (FileSystem.exists(path))
		return;

	final parent = Path.directory(path);
	if (parent != "" && parent != path && !FileSystem.exists(parent)) {
		createDirectoryRecursive(parent);
	}
	FileSystem.createDirectory(path);
}

function deleteRecursive(path:String) {
	if (!FileSystem.exists(path))
		return;

	if (FileSystem.isDirectory(path)) {
		for (entry in FileSystem.readDirectory(path)) {
			deleteRecursive(Path.join([path, entry]));
		}
		FileSystem.deleteDirectory(path);
	} else {
		FileSystem.deleteFile(path);
	}
}

function copyFile(src:String, dest:String) {
	final destDir = Path.directory(dest);
	if (!FileSystem.exists(destDir)) {
		createDirectoryRecursive(destDir);
	}
	File.copy(src, dest);
}

function setupReflaxe() {
	// Set up reflaxe as a dev library pointing to our bundled git submodule
	final reflaxePath = Path.join([shadeRoot, "git", "reflaxe"]);
	if (!FileSystem.exists(reflaxePath)) {
		printError('Error: reflaxe submodule not found at $reflaxePath');
		printError("Please run: git submodule update --init");
		Sys.exit(1);
		return;
	}

	// Run haxelib dev reflaxe to point to our bundled version
	// This is silent if already set up correctly
	final result = Sys.command("haxelib", ["dev", "reflaxe", reflaxePath]);
	if (result != 0) {
		printError("Error: Failed to set up reflaxe library");
		Sys.exit(1);
	}
}
