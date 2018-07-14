import ceylon.collection {
	ArrayList,
	MutableList
}
import ceylon.file {
	File,
	Nil
}
import ceylon.process {
	OverwriteFileOutput
}

import org.cook.core {
	Task,
	Project,
	Cache,
	TaskResult,
	projectPath,
	TaskPath,
	Input,
	CacheId,
	Error,
	Output
}
import org.cook.core.filesystem {
	AbsolutePath,
	RelativePath
}
import ceylon.json {
	JsonObject,
	JsonArray
}


" Jar creation task.
 
 
 
 
 "

shared class JarTask(
	"Relative to root"
	RelativePath jarRPath,
	String name_="jar",
	//JarOperation operation = JarOperation.create,
	Project? project_ = null, 
	Cache? cache_ = null
)
extends Task(name_, project_, cache_) 
{
	RelativePath basePath => projectPath(project_).basePath;

	class PathEntry(shared RelativePath pathBase, shared RelativePath path) 
	{
		shared JsonObject json(AbsolutePath root) => JsonObject{
			"pathBase" -> JsonArray(pathBase.elementStrings),
			"files" -> FileTree(root.append(pathBase)).jsonContent(path)
		};
	}
	
	MutableList<PathEntry> pathEntries = ArrayList<PathEntry>();

	"Add a path relative to another path, like in 'jar -C pathBase path'.
	 For example: addPath(RelativePath(\"target\", \"classes\"), RelativePath.current) includes all files in target/classes.
	 "
	shared JarTask addPath("from root" RelativePath pathBase, RelativePath path) {
		pathEntries.add(PathEntry(pathBase, path));
		return this;
	}
	
	String[] options(AbsolutePath root) {
		value result = ArrayList<String>();
		
		for(entry in pathEntries) {
			//if(exists pathBase = entry.pathBase) {
				result.add("-C");
				result.add(root.append(entry.pathBase).path.string);	// TODO: string?
			//}
			result.add(entry.path.string);	// TODO: string?
		}
		return result.sequence();
	}


	shared actual Input input => object satisfies Input {
		shared actual CacheId id() => CacheId(taskPath().elements.append(["in"]));
		
		shared actual JsonObject/*|Error*/ toJson(AbsolutePath root) => JsonObject{
			"options" -> JsonArray(options(root)),
			"files" -> JsonArray(pathEntries*.json(root))
		};
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
	};
	
	shared actual Output output => object satisfies Output {
		shared actual CacheId id() => CacheId(taskPath().elements.append(["out"]));
		
		shared actual JsonObject|Error toJson(AbsolutePath root) => JsonObject{
			"target" -> FileTree(root).jsonContent(basePath + jarRPath)
		};
		
		shared actual Error|Boolean updateFrom(JsonObject content, AbsolutePath root) {
			return FileTree(root).updateFrom(content, taskPath);
		}
		
		shared actual void updateTaskPath(TaskPath newTaskPath) {}
	};


	shared actual TaskResult execute(AbsolutePath root) {

		return doWithTemporaryDir<TaskResult>("javacTmp_",  (AbsolutePath tmpdirPath) {
			AbsolutePath optionsFilePath = tmpdirPath.append(RelativePath("jarOptions"));

			// Create arg ('@') file
			if(is Nil resource = optionsFilePath.resource) {
				File file = resource.createFile();
				value writer = file.Overwriter("UTF-8", 100k);
				options(root).each(writer.writeLine);
				writer.close();
			}
			
			OverwriteFileOutput logFilePath(String fileName) => 
					OverwriteFileOutput(tmpdirPath.path.childPath(fileName));

			TaskResult result = ShellExecution{
				command = "jar";
				projectBasePath = projectPath(project).basePath;
				args = {
					"cf", "``root.append(jarRPath).path``",
					"@``optionsFilePath.path``"
				};
				stdoutFileOutput = logFilePath("stdout.log");
				stderrFileOutput = logFilePath("stderr.log");
			}.execute(root);
			
			return result;
		});
	}
}
