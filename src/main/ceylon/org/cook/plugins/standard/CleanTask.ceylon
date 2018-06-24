import ceylon.file {
	File,
	Directory
}

import org.cook.core {
	categories,
	Cache,
	Project,
	Task,
	TaskResult,
	Success
}
import org.cook.core.filesystem {
	AbsolutePath,
	RelativePath,
	Visitor
}


shared class CleanTask(
	String name = "clean",
	"Relative to project root"
	RelativePath [] pathToClean = [],
	Project? parentProject = null,
	Cache? cache_ = null
)
 	extends Task(name, parentProject, cache_)
{
	category = categories.build;

	shared actual TaskResult execute(AbsolutePath projectRootPath) {
		
		for(path in pathToClean) {
			projectRootPath.visit(path, object satisfies Visitor {
				shared actual void file(RelativePath relativePath, File file) {
					file.delete();
				}
				shared actual void afterDirectory(RelativePath relativePath, Directory dir) {
					dir.delete();
				}
			} );
		}
		
		return Success("Clean succesful.");
	}
	
}