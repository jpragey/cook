import ceylon.file {
	temporaryDirectory,
	File
}
import ceylon.test {
	test
}

import org.cook.core {
	Project
}
import org.cook.core.filesystem {
	AbsolutePath
}
import org.cook.plugins.standard {
	FileCopyTask
}

import test.org.cook.core {
	TestDirEntry,
	TestFileEntry
}
class FileCopyTaskTest() 
{
	test
	shared void simpleCopyTest() {
		Project project = Project("root");
		value copyTask = FileCopyTask("copy", project);
		
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"),
			// source
			// +--- file0.txt
			// +--- subdir
			//      +--- file01.txt
			// +--- file1.txt
			// target
			sourceDir = TestDirEntry(projectRootDir, "source"),
			sourceFile0 = TestFileEntry(sourceDir, "file0.txt", "abc"),
			
			sourceSubDir = TestDirEntry(sourceDir, "subdir"),
			sourceSubFile01 = TestFileEntry(sourceSubDir, "file01.txt", "abc01"),
			
			sourceFile1 = TestFileEntry(sourceDir, "file1.txt", "abc1"),
			targetDir = TestDirEntry(projectRootDir, "target")
		)
		{
			
			copyTask.copyDir(AbsolutePath(sourceDir.path), AbsolutePath(targetDir.path));

			copyTask.execute(AbsolutePath(sourceDir.path)/*ignored*/);
			
			assert(is File f0 = targetDir.absolutePath("file0.txt").resource );
			assert(is File f01 = targetDir.absolutePath("subdir", "file01.txt").resource );
			//copyTask.copyDir(AbsolutePath(sourceFile1.path), AbsolutePath(targetDir.path));
			
			
			//assert(exists input0 = copyTask.inputCacheElements.first);
			//Input input = copyTask.input;
			//JsonObject objs = assertNotError(input.toJson());
			//
			//print(input.id().path);
			//print(objs.pretty);
		}
		
	}
	 
}