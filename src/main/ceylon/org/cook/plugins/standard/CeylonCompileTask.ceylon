import ceylon.file {
	Path,
	Nil,
	Directory,
	File,
	Link,
	temporaryDirectory
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
	Cache,
	ProjectPath
}
import org.cook.core.filesystem {
	AbsolutePath,
	RelativePath,
	Visitor
}
import ceylon.collection {
	ArrayList
}

shared class CeylonCompileTask(
	String name = "compileCeylon",

	"'--rep' option, relative to project root"
	RelativePath? repDirPath = null,
	
	"'--out' option, relative to project root"
	RelativePath? outDirPath = null,
	
	//"Java sources directory, relative to project base"
	//RelativePath srcDirRPath = RelativePath("src"),
	//"Build target directory, relative to project base"
	//RelativePath targetDirRPath = RelativePath("target"),
	Project? parentProject = null,
	shared Cache? cache = null
	
	
) 
		extends Task(name, parentProject)
{
	category = categories.build;
	
	shared actual String string => taskPath().string;
	
	shared actual Error|TaskResult execute(AbsolutePath root) {
		//print("  Project = ``project?.name else "<null>"``");
		//print("  Project (thid) = ``this.project?.name else "<null>"``");
		
		ProjectPath path = projectPath(project);
		//print("  ProjectPath = ``path``");
		
		RelativePath basePath => path.basePath; // Relative to root
		//print("  ProjectPath base = ``basePath``");
		
		//AbsolutePath projectBase = root.append(basePath);
		
		//Path targetDirPath = projectBase.append(targetDirRPath).path;
		//Path targetClassDirPath = targetDirPath.childPath("classes");	// Kept after compilation
		//if(is Nil d = targetClassDirPath.resource) {
		//	d.createDirectory(true);
		//}
		
		return doWithTemporaryDir("javacTmp_",  (AbsolutePath tmpdirPath) {
			// -- Javac temp files
			//Path classesFilePath = tmpdirPath.path.childPath("classes");
			
			//createClassesFile {
			//	root = root;
			//	classesFilePath = classesFilePath;
			//	projectBasePath = projectBase.path;
			//	srcDirectoryPath = srcDirRPath;
			//};
			
			OverwriteFileOutput logFilePath(String fileName) => 
					OverwriteFileOutput(tmpdirPath.path.childPath(fileName));

			//"'--rep' option, relative to project root"
			//RelativePath? repDirPath = null,
			//
			//"'--out' option, relative to project root"
			//RelativePath? outDirPath = null,

			ArrayList<String> args = ArrayList<String>{"compile"};
			
			// --rep
			if(exists p = repDirPath) {
				args.addAll{
					"--rep",
					root.append(p).string
				};
			}
			// --out
			if(exists p = outDirPath) {
				args.addAll{
					"--out",
					root.append(p).string
				};
			}

			
			ShellTaskResult|Error result = ShellExecution{
				command = "ceylon";
				projectBasePath = basePath;
				args = args;
				stdoutFileOutput = logFilePath("stdout.log");
				stderrFileOutput = logFilePath("stderr.log");
			}.execute(root);
			
			return result;
			
		});

		//return Success("");
	}
	
}

T doWithTemporaryDir<T>(String? prefix,  T(AbsolutePath) work  ) 
{
	void deleteDir(Directory dir) {
		for(child in dir.children()) {
			switch(child)
			case(is Directory) {deleteDir(child);}
			case(is File) {child.delete();}
			case(is Link) {/*TODO : error */}
		}
		dir.childDirectories().each(deleteDir);
		dir.delete();
	}
	
	try(Directory.TemporaryDirectory javacTmpDir = temporaryDirectory.TemporaryDirectory("prefix")) {
		javacTmpDir.deleteOnExit();
		AbsolutePath path = AbsolutePath(javacTmpDir.path);
		value result = work(path);
		
		deleteDir(javacTmpDir);
		return result;
	}
}

void createClassesFile(
	"Root project path"
	AbsolutePath root, 
	"Target file for java files list; will be created (must not exist)."
	Path classesFilePath,
	"Project base path (directory where the java tool will be called from)"
	Path projectBasePath,
	"Java sources directory"
	RelativePath srcDirectoryPath
)
{
	if(is Nil classesRes = classesFilePath.resource) {
		File file = classesRes.createFile(true);
		//file.deleteOnExit();
		try(writer = file.Overwriter()) {
			object v satisfies Visitor {
				
				
				shared actual void file(RelativePath ignored, File file) {
					Path path = file.path.relativePath(projectBasePath);
					String pathString = "/".join(path.elements);
					writer.writeLine(pathString);
				}
			}
			root.visit(srcDirectoryPath, v);
		}
	}
}
