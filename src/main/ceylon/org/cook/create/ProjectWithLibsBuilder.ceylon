import ceylon.file {
	current,
	Directory
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
	shared Integer buildHelloWorld(String projectName) {
		//String projectName = "projectName";
		String lib0Name = "lib0";
		String lib1Name = "lib1";
		
		assert(is Directory currentDir = current.resource);
		try(	projectDir = DirEntry(currentDir, projectName))
		{
			print("Creating application in ``currentDir.path``");
			buildLib(lib0Name, projectDir);			
			buildLib(lib1Name, projectDir);
			buildApp([lib0Name, lib1Name], projectDir);
			buildBuilder(projectDir);			
		}
		return exitCodes.ok;
	}
	
	void buildLib(String libName, DirEntry projectDir) {
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
		
		try (libDir = DirEntry(projectDir, libName),
			srcDir = DirEntry(libDir, "src"),

			ceylonDir = DirEntry(libDir, ".ceylon"),
			ceylonConfigFile = FileEntry(ceylonDir,  "config", ceylonConfigContent),

			srcMainDir = DirEntry(srcDir, "main"),
			srcMainCeylonDir = DirEntry(srcMainDir, "ceylon"),
			srcMainCeylonOrgDir = DirEntry(srcMainCeylonDir, "org"),
			srcMainCeylonOrgLibDir = DirEntry(srcMainCeylonOrgDir, libName),

			srcMainModuleFile = FileEntry(srcMainCeylonOrgLibDir,  "module.ceylon", moduleFileContent),
			srcMainPackageFile = FileEntry(srcMainCeylonOrgLibDir, "package.ceylon", packageFileContent),
			srcMainRunFile = FileEntry(srcMainCeylonOrgLibDir, "run.ceylon", runFileContent),
			
			srcTestDir = DirEntry(srcDir, "test"),
			srcTestCeylonDir = DirEntry(srcTestDir, "ceylon")
	
		) {
			print("Created library ``libName``");
		}
		
		catch(Exception e) {
			e.printStackTrace();
		}
	}

	void buildApp(String [] libnames, DirEntry projectDir) 
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
		
		try (libDir = DirEntry(projectDir, libName),
			srcDir = DirEntry(libDir, "src"),
			
			ceylonDir = DirEntry(libDir, ".ceylon"),
			ceylonConfigFile = FileEntry(ceylonDir,  "config", ceylonConfigContent),
			
			srcMainDir = DirEntry(srcDir, "main"),
			srcMainCeylonDir = DirEntry(srcMainDir, "ceylon"),
			srcMainCeylonOrgDir = DirEntry(srcMainCeylonDir, "org"),
			srcMainCeylonOrgLibDir = DirEntry(srcMainCeylonOrgDir, libName),
			
			srcMainModuleFile = FileEntry(srcMainCeylonOrgLibDir,  "module.ceylon", moduleFileContent),
			srcMainPackageFile = FileEntry(srcMainCeylonOrgLibDir, "package.ceylon", packageFileContent),
			srcMainRunFile = FileEntry(srcMainCeylonOrgLibDir, "run.ceylon", runFileContent),
			
			srcTestDir = DirEntry(srcDir, "test"),
			srcTestCeylonDir = DirEntry(srcTestDir, "ceylon")
			
		) {
			print("Created library ``libName``");
		}
		
		catch(Exception e) {
			e.printStackTrace();
		}

		print("Created application");
		
	}
	
	
	void buildBuilder(DirEntry projectDir) 
	{
		String libName = "build";
		
		String moduleFileContent =
				"
				 native(\"jvm\")
				 module org.``libName`` \"1.0.0\" {
				 
                      shared import org.cook.core \"0.0.1\";
				      import org.cook.plugins.standard \"0.0.1\";
              }
              ";
		String packageFileContent =
				"shared package org.``libName``;
				 
				 ";
		String runFileContent =
				"""
				   import org.cook.core {
				   Project,
				   Executor
				   }
				   import org.cook.plugins.standard {
				   CeylonCompileTask
				   }
				   import org.cook.core.filesystem {
				   RelativePath
				   }
				   
				   suppressWarnings("expressionTypeNothing") // because of process.exit()
				   shared void run() 
				   {
				       Project root = Project("root");
				       Project lib0 = Project("lib0");
				       Project lib1 = Project("lib1");
				       Project app = Project("app");
				       root.addChildrenProjects(lib0, lib1, app);

 				  	   // Store all modules in <root>/modules/
				       value repoPath = RelativePath("modules");
				       value compileTask => CeylonCompileTask("compile", repoPath, repoPath);
				                                                                                                                                                                                                          
	                   lib0.addTask(compileTask);
	                   lib1.addTask(compileTask);
                       app.addTask(compileTask);
                  
	                   Integer exitCode = Executor().execute(root);
				       process.exit(exitCode);
                   }
                   
				   """;
		String ceylonConfigContent = 
				"[defaults]
				 encoding=UTF-8
				 
				 [compiler]
				 source=src/main/ceylon
				 source=src/test/ceylon
				 resource=resource
				 ";
		
		try (libDir = DirEntry(projectDir, libName),
			srcDir = DirEntry(libDir, "src"),
			
			ceylonDir = DirEntry(libDir, ".ceylon"),
			ceylonConfigFile = FileEntry(ceylonDir,  "config", ceylonConfigContent),
			
			srcMainDir = DirEntry(srcDir, "main"),
			srcMainCeylonDir = DirEntry(srcMainDir, "ceylon"),
			srcMainCeylonOrgDir = DirEntry(srcMainCeylonDir, "org"),
			srcMainCeylonOrgLibDir = DirEntry(srcMainCeylonOrgDir, libName),
			
			srcMainModuleFile = FileEntry(srcMainCeylonOrgLibDir,  "module.ceylon", moduleFileContent),
			srcMainPackageFile = FileEntry(srcMainCeylonOrgLibDir, "package.ceylon", packageFileContent),
			srcMainRunFile = FileEntry(srcMainCeylonOrgLibDir, "run.ceylon", runFileContent),
			
			srcTestDir = DirEntry(srcDir, "test"),
			srcTestCeylonDir = DirEntry(srcTestDir, "ceylon")
			
		) {
			print("Created build project ``libName``");
		}
		
		catch(Exception e) {
			e.printStackTrace();
		}
		
		print("Created application");
		
	}
}
