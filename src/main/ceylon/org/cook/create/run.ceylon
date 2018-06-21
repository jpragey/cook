import ceylon.file {
	Path,
	File,
	Nil,
	Directory,
	current
}

object exitCodes {
	shared Integer ok = 0;
	shared Integer failed = 1;
}

""
suppressWarnings("expressionTypeNothing")
shared void run() {
	Integer exitCode = ProjectWithLibsBuilder().buildHelloWorld();
	process.exit(exitCode);
}

"
 
     current
       +- <project name> dir
          +- lib0/
             +- src/main/ceylon
             | +-- org.lib0/{module.ceylon, package.ceylon, run.ceylon}
             +- src/test/ceylon
               +-- test.org.lib0/{module.ceylon, package.ceylon, run.ceylon, Lib0Test.ceylon}
               
          +- lib1/
             +- src/main/ceylon
             | +-- org.lib1/{module.ceylon, package.ceylon, run.ceylon}
             +- src/test/ceylon
               +-- test.org.lib0/{module.ceylon, package.ceylon, run.ceylon, Lib0Test.ceylon}
               
          +- app/
             +- src/main/ceylon
             | +-- org.app/{module.ceylon, package.ceylon, run.ceylon}
             +- src/test/ceylon
               +-- test.org.app/{module.ceylon, package.ceylon, run.ceylon, Lib0Test.ceylon}
 "
class ProjectWithLibsBuilder() {
	shared Integer buildHelloWorld() {
		String projectName = "projectName";
		String lib0Name = "lib0";
		String lib1Name = "lib1";
		
		assert(is Directory currentDir = current.resource);
		try(	projectDir = TestDirEntry(currentDir, projectName))
		{
			print("Creating application in ``currentDir.path``");
			buildLib(lib0Name, projectDir);			
			buildLib(lib1Name, projectDir);
			buildApp([lib0Name, lib1Name], projectDir);			
		}
		return exitCodes.ok;
	}
	
	void buildLib(String libName, TestDirEntry projectDir) {
		String moduleFileContent =
				"module org.``libName`` \"1.0.0\" {
				 }
				 ";
		String packageFileContent =
				"shared package org.``libName``;
				 ";
		String runFileContent =
				"
				 shared void run() {
				 	print(\"Hello World from ``libName`` \");
                 }
				 ";
		String ceylonConfigContent = 
				"[defaults]
				 encoding=UTF-8
				 
				 [compiler]
				 source=src/main/ceylon
				 source=src/test/ceylon
				 resource=resource
				 ";
		
		try (libDir = TestDirEntry(projectDir, libName),
			srcDir = TestDirEntry(libDir, "src"),

			ceylonDir = TestDirEntry(libDir, ".ceylon"),
			ceylonConfigFile = TestFileEntry(ceylonDir,  "config", ceylonConfigContent),

			srcMainDir = TestDirEntry(srcDir, "main"),
			srcMainCeylonDir = TestDirEntry(srcMainDir, "ceylon"),
			srcMainCeylonOrgDir = TestDirEntry(srcMainCeylonDir, "org"),
			srcMainCeylonOrgLibDir = TestDirEntry(srcMainCeylonOrgDir, libName),

			srcMainModuleFile = TestFileEntry(srcMainCeylonOrgLibDir,  "module.ceylon", moduleFileContent),
			srcMainPackageFile = TestFileEntry(srcMainCeylonOrgLibDir, "package.ceylon", packageFileContent),
			srcMainRunFile = TestFileEntry(srcMainCeylonOrgLibDir, "run.ceylon", runFileContent),
			
			srcTestDir = TestDirEntry(srcDir, "test"),
			srcTestCeylonDir = TestDirEntry(srcTestDir, "ceylon")
	
		) {
			print("Created library ``libName``");
		}
		
		catch(Exception e) {
			e.printStackTrace();
		}
	}

	void buildApp(String [] libnames, TestDirEntry projectDir) 
	{
		String libName = "app";
		String moduleFileContent =
				"module org.``libName`` \"1.0.0\" {
				   `` "\n".join{for(libName in libnames) "  shared import org.``libName`` \"1.0.0\"; "} ``
				 }
				 ";
		String packageFileContent =
				"shared package org.``libName``;
				 ";
		String runFileContent =
				"
				 import org.lib0 {
				   run0 = run
				 }
				 import org.lib1 {
				   run1 = run
				 }
				 shared void run() {
				 	print(\"Hello World from ``libName`` \");
				 	run0();
				 	run1();
				 }
				 ";
		String ceylonConfigContent = 
				"[defaults]
				 encoding=UTF-8
				 
				 [compiler]
				 source=src/main/ceylon
				 source=src/test/ceylon
				 resource=resource
				 ";
		
		try (libDir = TestDirEntry(projectDir, libName),
			srcDir = TestDirEntry(libDir, "src"),
			
			ceylonDir = TestDirEntry(libDir, ".ceylon"),
			ceylonConfigFile = TestFileEntry(ceylonDir,  "config", ceylonConfigContent),
			
			srcMainDir = TestDirEntry(srcDir, "main"),
			srcMainCeylonDir = TestDirEntry(srcMainDir, "ceylon"),
			srcMainCeylonOrgDir = TestDirEntry(srcMainCeylonDir, "org"),
			srcMainCeylonOrgLibDir = TestDirEntry(srcMainCeylonOrgDir, libName),
			
			srcMainModuleFile = TestFileEntry(srcMainCeylonOrgLibDir,  "module.ceylon", moduleFileContent),
			srcMainPackageFile = TestFileEntry(srcMainCeylonOrgLibDir, "package.ceylon", packageFileContent),
			srcMainRunFile = TestFileEntry(srcMainCeylonOrgLibDir, "run.ceylon", runFileContent),
			
			srcTestDir = TestDirEntry(srcDir, "test"),
			srcTestCeylonDir = TestDirEntry(srcTestDir, "ceylon")
			
		) {
			print("Created library ``libName``");
		}
		
		catch(Exception e) {
			e.printStackTrace();
		}

		print("Created application");
		
	}
}

shared interface TestEntry satisfies Destroyable {
	shared formal Path path;
	shared default actual String string => path.string;
}

shared class TestDirEntry(
	Directory|TestDirEntry parent, shared String name/*, {TestEntry(TestEntry) *} children*/
) satisfies TestEntry 
{
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);
	
	
	assert(is Nil res = parentPath.childPath(name).resource);
	res.createDirectory(true);
	
	//TestEntry[] child = [for(c in children) c(super)];
	
	void deepDelete(Directory dir) {
		//Directory dir
		dir.childDirectories().each(deepDelete);
		for(res in dir.children()) {
			switch(res)
			case(is Directory) {deepDelete(res);}
			case(is File) {res.delete();}
			else{}
		}
		dir.delete();
	}
	
	shared actual void destroy(Throwable? error) {
		//deepDelete(dir);
	}
}


shared class TestFileEntry(Directory|TestDirEntry parent, String name, String|<Byte[]>? content = null) satisfies TestEntry {
	shared /*actual*/ Path parentPath = if(is Directory parent) then parent.path else parent.path;
	shared actual Path path = parentPath.childPath(name);
	
	assert(is Nil res = path.resource);
	File file = res.createFile(true);
	if(exists content) {
		try(writer = file.Overwriter("utf-8", 10_000)) {
			if(is String content) {
				writer.write(content);
			} else {
				writer.writeBytes(content);
			}
		}
		
	}
	
	
	shared actual void destroy(Throwable? error) {
		//file.delete();
	}
}
