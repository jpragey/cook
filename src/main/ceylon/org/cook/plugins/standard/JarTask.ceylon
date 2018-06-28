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
	projectPath
}
import org.cook.core.filesystem {
	AbsolutePath,
	RelativePath
}

//shared class JarOperation {
//	"Command-line letter" shared String val;
//	shared new (String val) {
//		this.val = val;
//	}
//
//	shared new create extends JarOperation("c") {}
//	shared new extract extends JarOperation("x") {}
//	
//}




shared class JarTask(
	"Relative to root"
	RelativePath jarFile,
	String name_="jar",
	//JarOperation operation = JarOperation.create,
	Project? project_ = null, 
	Cache? cache_ = null
)
extends Task(name_, project_, cache_) 
{
	class PathEntry(shared RelativePath? pathBase, shared {RelativePath *} paths) {}
	
	MutableList<PathEntry> pathEntries = ArrayList<PathEntry>();

	shared JarTask addPath(RelativePath? pathBase, {RelativePath *} paths) {
		pathEntries.add(PathEntry(pathBase, paths));
		return this;
	}
	
	shared String[] options(AbsolutePath root) {
		value result = ArrayList<String>();
		
		for(entry in pathEntries) {
			if(exists pathBase = entry.pathBase) {
				result.add("-C");
				result.add(root.append(pathBase).path.string);	// TODO: string?
			}
			for(path in entry.paths) {
				result.add(path.string);	// TODO: string?
			}
			
		}
		return result.sequence();
	}

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
					"cf", "``root.append(jarFile).path``",
					"@``optionsFilePath.path``"
				};
				stdoutFileOutput = logFilePath("stdout.log");
				stderrFileOutput = logFilePath("stderr.log");
			}.execute(root);
			
			return result;
		});
	}
}
