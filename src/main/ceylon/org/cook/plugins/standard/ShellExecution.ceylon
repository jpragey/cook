import ceylon.file {
	Path,
	File,
	Directory
}
import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath
}
import ceylon.process {
	OverwriteFileOutput,
	Process,
	createProcess
}
import ceylon.collection {
	ArrayList
}
import org.cook.core {
	Error,
	TaskResult
}

shared class ShellTaskResult(shared Integer exitValue, shared String[] outLog, shared String[] errLog) 
satisfies TaskResult
{
	
	shared actual Boolean canContinue => true;
	
}

shared class ShellExecution(shared String command,
	
	RelativePath projectBasePath,
	{String *} args = {},
	OverwriteFileOutput? stdoutFileOutput = null,
	OverwriteFileOutput? stderrFileOutput = null
) 
{
	shared void deleteTempFile(Path path) {
		if(is File file = path.resource) {
			file.delete();
		}					
	}
	void deleteDir(Directory dir) {
		dir.childDirectories().each(deleteDir);
		dir.delete();
	}

	shared Error|ShellTaskResult execute(AbsolutePath projectRootPath) {
		//Path stdoutLogPath = logDirPath.childPath("stdout.log");
		//Path stderrLogPath = logDirPath.childPath("stderr.log");
		value processPath = projectRootPath.append(projectBasePath).path;
		
		//// TODO: log
		//print("Executing ``command``  ``args`` ");
		//print("  Process path: ``processPath`` ");
		//print("  Process base path: ``projectBasePath`` ");
		
		Process process = createProcess {
			command = command;
			arguments = args;
			//path = projectBasePath.from(projectRootPath.path);
			path = processPath;
			output = stdoutFileOutput;
			error  = stderrFileOutput;
		};
		
		Integer exitCode = process.waitForExit();
		//print("Exit code: ``exitCode``");
		
		String[] readAndDeleteLogFile(OverwriteFileOutput? fileOutput/* Path path*/) {
			if(exists fileOutput) {
				value path = fileOutput.path;
				if(is File file = path.resource) {
					ArrayList<String>  lines = ArrayList<String>(); 
					try (reader = file.Reader("utf-8")) {
						while(exists line = reader.readLine()) {
							lines.add(line);
						}
					}
					file.delete();
					return lines.sequence();
				} else {
					throw Exception("Can't read log file ``path``");
				}
			} else {
				return [];
			}
			
		}
		
		String[] errLog = readAndDeleteLogFile(stderrFileOutput);
		String[] outLog = readAndDeleteLogFile(stdoutFileOutput);
		print("out: \n`` "\n".join(outLog) ``");
		print("err: \n`` "\n".join(errLog) ``");
		
		return ShellTaskResult(exitCode, outLog, errLog);
	}
}