import ceylon.file {
	Path,
	Nil
}
import ceylon.json {
	JsonObject
}
import ceylon.process {
	OverwriteFileOutput
}

import org.cook.core {
	Task,
	categories,
	TaskResult,
	projectPath,
	Project,
	Cache,
	Input,
	CacheId,
	Error,
	TaskPath,
	Output
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
	
	shared actual Input input => object satisfies Input {
		shared actual CacheId id() => CacheId(taskPath().elements.append(["in"]));

		shared actual JsonObject/*|Error*/ toJson(AbsolutePath root) => JsonObject{
			"source" -> FileTree(root).jsonContent(srcDirRPath)
		};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
		
		
	};
	
	shared actual Output output => object satisfies Output {
		shared actual CacheId id() => CacheId(taskPath().elements.append(["out"]));
		
		shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{
			"target" -> FileTree(root).jsonContent(targetDirRPath)
		};
		
		shared actual Error|Boolean updateFrom(JsonObject content, AbsolutePath root) {
			return FileTree(root).updateFrom(content, taskPath);
		}
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
	};
	
	shared actual TaskResult execute(AbsolutePath root) {
		RelativePath basePath = projectPath(project).basePath; // Relative to root
		
		AbsolutePath projectBase = root.append(basePath);
		
		Path targetDirPath = projectBase.append(targetDirRPath).path;
		Path targetClassDirPath = targetDirPath.childPath("classes");	// Kept after compilation
		if(is Nil d = targetClassDirPath.resource) {
			d.createDirectory(true);
		}
		
		return doWithTemporaryDir<TaskResult>("javacTmp_",  (AbsolutePath tmpdirPath) {
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
			
			TaskResult result = ShellExecution{
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
	}
	
}
