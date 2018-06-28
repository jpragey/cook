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
	AbsolutePath
}




shared class JarExtractTask(
	""
	AbsolutePath jarFile,
	String name_="jarExtract",
	Project? project_ = null, 
	Cache? cache_ = null
)
extends Task(name_, project_, cache_) 
{

	shared actual TaskResult execute(AbsolutePath root) {

		return doWithTemporaryDir<TaskResult>("javacTmp_",  (AbsolutePath tmpdirPath) {
			
			OverwriteFileOutput logFilePath(String fileName) => 
					OverwriteFileOutput(tmpdirPath.path.childPath(fileName));

			TaskResult result = ShellExecution{
				command = "jar";
				projectBasePath = projectPath(project).basePath;
				args = {
					"xf", "``jarFile.path``"
				};
				stdoutFileOutput = logFilePath("stdout.log");
				stderrFileOutput = logFilePath("stderr.log");
			}.execute(root);
			
			return result;
		});
	}
}
