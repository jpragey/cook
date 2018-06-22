import ceylon.file {
	Path,
	Nil
}
import ceylon.process {
	OverwriteFileOutput
}

import org.cook.core {
	Task,
	categories,
	Error,
	TaskResult,
	projectPath,
	Project,
	Cache
}
import org.cook.core.filesystem {
	AbsolutePath,
	RelativePath
}

shared class JavaCompileTask(
	String name = "compileJava",
	
	"Java sources directory, relative to project base"
	RelativePath srcDirRPath = RelativePath("src"),
	"Build target directory, relative to project base"
	RelativePath targetDirRPath = RelativePath("target"),
	Project? project = null,
	shared Cache? cache_ = null
	
	
) 
		extends Task(name, project, cache_)
{
	category = categories.build;
	
	
	shared actual Error|TaskResult execute(AbsolutePath root) {
		RelativePath basePath = projectPath(project).basePath; // Relative to root
		
		AbsolutePath projectBase = root.append(basePath);
		
		Path targetDirPath = projectBase.append(targetDirRPath).path;
		Path targetClassDirPath = targetDirPath.childPath("classes");	// Kept after compilation
		if(is Nil d = targetClassDirPath.resource) {
			d.createDirectory(true);
		}
		
		return doWithTemporaryDir("javacTmp_",  (AbsolutePath tmpdirPath) {
			// -- Javac temp files
			Path classesFilePath = tmpdirPath.path.childPath("classes");
			
			createClassesFile {
				root = root;
				classesFilePath = classesFilePath;
				projectBasePath = projectBase.path;
				srcDirectoryPath = srcDirRPath;
			};
			
			OverwriteFileOutput logFilePath(String fileName) => 
					OverwriteFileOutput(tmpdirPath.path.childPath(fileName));
			
			ShellTaskResult|Error result = ShellExecution{
				command = "javac";
				projectBasePath = basePath;
				args = {
					"-d", "``targetClassDirPath``",
					"@``classesFilePath``"
				};
				stdoutFileOutput = logFilePath("stdout.log");
				stderrFileOutput = logFilePath("stderr.log");
			}.execute(root);
			
			return result;
			
		});

		//return Success("");
	}
	
}
