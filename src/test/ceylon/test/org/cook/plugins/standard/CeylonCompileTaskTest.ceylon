import ceylon.test {
	test,
	tag
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
	AbsolutePath,
	RelativePath
}

class CeylonCompileTaskTest() 
{
	test
	tag("integration")
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
			CeylonCompileTask task = CeylonCompileTask {
				name = "compile";
				repDirPath = null;
				outDirPath = RelativePath("custom-modules");
				parentProject = project;
			};

			assertNotError(task.execute(AbsolutePath(projectRootDir.path)));
			
			////assert(is Directory modulesDir = projectRootDir.path.childPath("modules").resource);
			assert(is Directory modulesDir = projectRootDir.path.childPath("custom-modules").resource);
			
		}
	}
	
	
	" Compile in <root>/child0/child1 project"
	test
	tag("integration")
	shared void compilationInSubprojectTest() {
		
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
		
		Project rootProject = Project("root");
		Project child0 = Project("child0");
		rootProject.addChildrenProjects(child0);
		Project child1 = Project("child1");
		child0.addChildrenProjects(child1);

		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			child0Dir = TestDirEntry(projectRootDir, "child0"),
			child1Dir = TestDirEntry(child0Dir, "child1"),
			
			sourceDir = TestDirEntry(child1Dir, "source"),
			sourceOrgDir = TestDirEntry(sourceDir, "org"),
			sourceOrgAppDir = TestDirEntry(sourceOrgDir, "app"),
			sourceOrgAppModule  = TestFileEntry(sourceOrgAppDir, "module.ceylon", moduleFileContent),
			sourceOrgAppPackage = TestFileEntry(sourceOrgAppDir, "package.ceylon", packageFileContent),
			sourceOrgAppRun     = TestFileEntry(sourceOrgAppDir, "run.ceylon", runFileContent)
		)
		{
			CeylonCompileTask task = CeylonCompileTask {
				name = "compile";
				repDirPath = null;
				outDirPath = RelativePath("custom-modules");
				parentProject = child1;
			};
			
			assertNotError(task.execute(AbsolutePath(projectRootDir.path)));
			
			////assert(is Directory modulesDir = projectRootDir.path.childPath("modules").resource);
			assert(is Directory modulesDir = projectRootDir.path.childPath("custom-modules").resource);
			
		}
	}
	
	
}