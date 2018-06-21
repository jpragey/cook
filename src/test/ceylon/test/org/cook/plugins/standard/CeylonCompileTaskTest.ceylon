import ceylon.test {
	test
}
import ceylon.file {
	temporaryDirectory,
	Directory
}
import test.org.cook.core {
	TestDirEntry,
	TestFileEntry,
	assertNotError
}
import org.cook.plugins.standard {
	CeylonCompileTask
}
import org.cook.core {
	Project
}
import org.cook.core.filesystem {
	AbsolutePath
}

class CeylonCompileTaskTest() 
{
	test
	shared void basicCompilationTest() {
		
		String moduleFileContent =
				"module org.app \"1.0.0\" {
				 }
				 ";
		String packageFileContent =
				"shared package org.app;
				 ";
		String runFileContent =
				"
				 shared void run() {
				 	print(\"Hello World from app\");
				 }
				 ";

		Project project = Project("root");
		
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			sourceDir = TestDirEntry(projectRootDir, "source"),
			sourceOrgDir = TestDirEntry(sourceDir, "org"),
			sourceOrgAppDir = TestDirEntry(sourceOrgDir, "app"),
			sourceOrgAppModule  = TestFileEntry(sourceOrgAppDir, "module.ceylon", moduleFileContent),
			sourceOrgAppPackage = TestFileEntry(sourceOrgAppDir, "package.ceylon", packageFileContent),
			sourceOrgAppRun     = TestFileEntry(sourceOrgAppDir, "run.ceylon", runFileContent)
		)
		{
			CeylonCompileTask task = CeylonCompileTask("compile", project);

			assertNotError(task.execute(AbsolutePath(projectRootDir.path)));
			
			assert(is Directory modulesDir = projectRootDir.path.childPath("modules").resource);
			
		}
	}
}