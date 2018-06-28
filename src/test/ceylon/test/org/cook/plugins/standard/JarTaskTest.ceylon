import ceylon.file {
	temporaryDirectory,
	File
}
import ceylon.test {
	test,
	tag
}

import org.cook.core.filesystem {
	RelativePath,
	AbsolutePath,
	current
}
import org.cook.plugins.standard {
	JarTask,
	JarExtractTask
}

import test.org.cook.core {
	TestDirEntry,
	TestFileEntry,
	assertNotError
}

class JarTaskTest() 
{
	test
	tag("integration")
	shared void basicjarTest() {
		
		/* <root>
		 * +-- source/
		 *     +-- {f0.txt, f1.txt}
		 *     +-- sub0/sub1/{f2.txt, f3.txt}
		 * +-- all.jar
		 * +-- target/
		 
		 */
		try(projectRootDir = temporaryDirectory.TemporaryDirectory("cookTest_"), 
			sourceDir = TestDirEntry(projectRootDir, "source"),
			sourceF0  = TestFileEntry(sourceDir, "f0.txt", "f0"),
			sourceF1  = TestFileEntry(sourceDir, "f1.txt", "f1"),
			sourceSub0Dir     = TestDirEntry(sourceDir,     "sub0"),
			sourceSub0Sub1Dir = TestDirEntry(sourceSub0Dir, "sub1"),
			sourceSub0Sub1F2 = TestFileEntry(sourceSub0Sub1Dir, "f2.txt", "f2"),
			sourceSub0Sub1F3 = TestFileEntry(sourceSub0Sub1Dir, "f3.txt", "f3"),
			
			targetDir = TestDirEntry(projectRootDir, "target")
		)
		{
			RelativePath jarPath = RelativePath("all.jar");
			JarTask task = JarTask(jarPath);
			
			task.addPath(RelativePath("source"), {RelativePath(current)});
			
			value rootDirPath = AbsolutePath(projectRootDir.path);
			assertNotError(task.execute(rootDirPath));
			
			assert(is File jar = rootDirPath.append(jarPath).path.resource);
			
			// -- Extract
			JarExtractTask extractTask = JarExtractTask {
				jarFile = AbsolutePath(projectRootDir.path).append(jarPath);
			};
			
			assertNotError(extractTask.execute(rootDirPath.append(RelativePath("target"))));
			
			assert(is File extractedF2 = targetDir.absolutePath("sub0", "sub1", "f2.txt").path.resource);
			assert(is File extractedManifest = targetDir.absolutePath("META-INF/MANIFEST.MF").path.resource);
			
		}
	}
}